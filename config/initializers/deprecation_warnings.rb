ActiveSupport::Notifications.subscribe('deprecation.rails') do |name, start, finish, id, payload|
  if Settings.feature_flags.report_deprecations
    Honeybadger.notify(
      error_class:   "deprecation_warning",
      error_message: payload[:message],
      backtrace:     payload[:callstack]
    )
  end
end
