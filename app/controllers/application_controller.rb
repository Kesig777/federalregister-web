class ApplicationController < ActionController::Base
  include RouteBuilder
  helper RouteBuilder

  include RouteBuilder::Authentication
  helper RouteBuilder::Authentication

  include OmniauthHelper
  helper OmniauthHelper

  protect_from_forgery if: :current_user

  before_action :authenticate_user!

  before_action :set_page_to_track

  around_filter :log_memory_usage unless Rails.env.test?

  if Rails.env.development? && Settings.vcr.enabled
    around_filter :use_vcr
  end

  def set_page_to_track
    @page_to_track = params[:page_to_track]
  end

  def cache_for(time)
    if !Rails.env.development? || Settings.varnish.enable_cache_headers
      expires_in time, :public => true
    end
  end

  def authenticate_user!
    session[:redirect_to] = current_url unless redirect_blacklist.include?(current_path)
    redirect_to sign_in_url unless current_user
  end

  private

  def current_url
    request.url
  end

  def current_path
    request.path
  end

  def redirect_blacklist
    []
  end

  def parse_date_from_params
    year  = params[:year]
    month = params[:month]
    day   = params[:day] || "01"
    begin
      Date.parse("#{year}-#{month}-#{day}")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
  end

  rescue_from FederalRegister::Client::RecordNotFound, with: :not_found

  rescue_from Exception, :with => :server_error
  def server_error(exception)
    Rails.logger.error(exception)
    honeybadger_options = {:exception => exception}
    honeybadger_options[:environment_name] = "#{Rails.env}_scanbot" if request.user_agent =~ /ScanAlert/
    Honeybadger.notify(honeybadger_options)

    raise exception
  end

  rescue_from ActionView::MissingTemplate, :with => :missing_template
  def missing_template(exception)
    if exception.is_a?(ActionView::MissingTemplate) &&
      !Collector.new(collect_mimes_from_class_level).negotiate_format(request)
      render :nothing => true, :status => 406
    else
      raise exception
    end
  end

  def use_vcr
    VCR.eject_cassette
    VCR.use_cassette(Settings.vcr.cassette) { yield }
  end

  def rescue_action_in_public_with_honeybadger(exception)
    rescue_action_in_public_without_honeybadger(exception)
  end

  # throw exception rather than just resetting session on XSRF error
  # in Rails 4 just use `protect_from_forgery with: exception`
  def handle_unverified_request
    if Rails.env.development?
      raise ActionController::InvalidAuthenticityToken
    else
      reset_session
    end
  end

  def log_memory_usage
    pid = Process.pid

    start_mem = Process.getrusage.maxrss
    yield
    end_mem = Process.getrusage.maxrss

    Rails.logger.warn "[memory usage: #{pid} #{start_mem} #{end_mem} #{end_mem-start_mem}]"
  end
end
