######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:16.04

# Update apt
RUN apt-get update && apt-get install vim curl build-essential -y


#######################
### RUBY
#######################

RUN apt-get install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y ruby1.9.3 ruby1.9.1-dev


#######################
### VARIOUS PACKAGES
#######################

# libqt4-dev libqtwebkit-dev are for capybara-webkit
RUN apt-get update && apt-get install -y build-essential libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev mysql-client libqt4-dev libqtwebkit-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# npm packages for testing
RUN npm install -g jshint
RUN npm install -g coffeelint


##################
### TIMEZONE
##################

RUN ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime


##################
### SERVICES
##################

COPY docker/web/my_init.d /etc/my_init.d
COPY docker/web/service/web/run /etc/service/web/run
COPY docker/web/service/resque_worker_1/run /etc/service/resque_worker_1/run
COPY docker/web/service/resque_worker_2/run /etc/service/resque_worker_2/run
COPY docker/web/service/resque_worker_3/run /etc/service/resque_worker_3/run

RUN adduser app -uid 1000 --system
RUN usermod -a -G docker_env app


###############################
### GEMS & PASSENGER INSTALL
###############################

RUN gem install bundler --version 1.13.6

WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system --full-index &&\
  passenger-config install-standalone-runtime &&\
  passenger start --runtime-check-only

ENV PASSENGER_MIN_INSTANCES 1
ENV WEB_PORT 3000


##################
### APP
##################

COPY . /home/app/

WORKDIR /home/app
RUN mkdir -p /home/app/tmp/pids
RUN chown -R app /home/app

RUN DB_ADAPTER=nulldb DEVISE_SECRET_KEY=XXX AWS_ACCESS_KEY_ID=XXX AWS_SECRET_ACCESS_KEY=XXX RAILS_ENV=production bundle exec rake assets:precompile &&\
  chown -R app /home/app

# CI setup
RUN mkdir log/test/ && touch log/test/vcr.log


##################
### BASE (LAST)
##################

# ensure all packages are up to date
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
