require "bundler"
Bundler.setup(:default, :deployment)

# deploy recipes - need to do `sudo gem install thunder_punch` - these should be required last
require 'thunder_punch'

#############################################################
# Set Basics
#############################################################
set :application, "my_fr2"
set :user, "deploy"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end

# use these settings for making AMIs with thunderpunch
# set :user, "ubuntu"
#ssh_options[:keys] = [File.join('~/Documents/AWS/FR2', "gpoEC2.pem")]


ssh_options[:paranoid] = false
set :use_sudo, true
default_run_options[:pty] = true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }


set :finalize_deploy, false
# we don't need this because we have an asset server
# and we also use varnish as a cache server. Thus 
# normalizing timestamps is detrimental.
set :normalize_asset_timestamps, false


set :migrate_target, :current


#############################################################
# General Settings  
#############################################################

set :deploy_to,  "/var/www/apps/#{application}" 

#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'production'
  
  role :proxy, "ec2-184-72-241-172.compute-1.amazonaws.com"
  role :app, "ec2-204-236-209-41.compute-1.amazonaws.com", "ec2-184-72-139-81.compute-1.amazonaws.com", "ec2-174-129-132-251.compute-1.amazonaws.com", "ec2-72-44-36-213.compute-1.amazonaws.com", "ec2-204-236-254-83.compute-1.amazonaws.com"
  role :db, "ec2-50-17-38-106.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-50-17-38-106.compute-1.amazonaws.com"
  role :static, "ec2-107-20-145-32.compute-1.amazonaws.com" #monster image
  role :worker, "ec2-107-20-145-32.compute-1.amazonaws.com", {:primary => true} #monster image

  # Database Settings
  set :remote_db_name, "#{application}_#{rails_env}"
  set :db_path,        "#{current_path}/db"
  set :sql_file_path,  "#{current_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging" 
  set :branch, `git branch`.match(/\* (.*)/)[1]
  
  role :proxy,  "ec2-184-72-250-132.compute-1.amazonaws.com"
  role :app,    "ec2-50-19-14-105.compute-1.amazonaws.com"
  role :db,     "ec2-50-16-6-83.compute-1.amazonaws.com", {:primary => true}
  role :sphinx, "ec2-50-16-6-83.compute-1.amazonaws.com"

  role :static, "ec2-184-72-163-77.compute-1.amazonaws.com"
  role :worker, "ec2-184-72-163-77.compute-1.amazonaws.com", {:primary => true}

  # Database Settings
  set :remote_db_name, "#{application}_#{rails_env}"
  set :db_path,        "#{current_path}/db"
  set :sql_file_path,  "#{current_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"
end


#############################################################
# SCM Settings
#############################################################
set :scm,              :git          
set :github_user_repo, 'criticaljuncture'
set :github_project_repo, 'my_fr2'
set :deploy_via,       :remote_cache
set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
set :github_username, 'criticaljuncture' 


#############################################################
# Git
#############################################################

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :git_enable_submodules, true


#############################################################
# Bundler
#############################################################
# this should list all groups in your Gemfile (except default)
set :gem_file_groups, [:deployment, :development, :test]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!
# all deployment changes that affect app servers also must 
# be put in the user-scripts files on s3!!!

after "deploy:update_code",              "deploy:set_rake_path"
after "deploy:set_rake_path",            "bundler:fix_bundle"
after "bundler:fix_bundle",              "deploy:migrate"
after "deploy:migrate",                  "assets:create_sprite_scss_files"
after "assets:create_sprite_scss_files", "assets:precompile"
after "assets:precompile",               "passenger:restart"
after "passenger:restart",               "varnish:clear_cache"


#############################################################
#                                                           #
#                                                           #
#                         Recipes                           #
#                                                           #
#                                                           #
#############################################################

namespace :apache do
  desc "Restart Apache Servers"
  task :restart, :roles => [:app] do
    sudo '/etc/init.d/apache2 restart'
  end
end

namespace :my_fr2 do
  desc "Update api keys"
  task :update_api_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:api_keys.yml #{current_path}/config/api_keys.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update secret keys"
  task :update_secret_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:secrets.yml #{current_path}/config/secrets.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update sendgrid keys"
  task :update_sendgrid_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:sendgrid.yml #{current_path}/config/sendgrid.yml"
    find_and_execute_task("apache:restart")
  end
end

namespace :assets do
  task :create_sprite_scss_files, :roles => [:static] do
    run "cd #{current_path} && bundle exec compass sprite -c config/compass.rb 'icons/my_fr2/*.png' --force"
    run "cd #{current_path} && bundle exec compass sprite -c config/compass.rb 'icons/my_fr2/user_utils/*.png' --force"
  end

  task :precompile do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end
end

require 'airbrake/capistrano'

