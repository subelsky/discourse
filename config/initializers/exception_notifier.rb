# https://github.com/smartinez87/exception_notification

if Rails.env.production?
  Discourse::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[HackBaltimoreException] ",
    :sender_address => %{"notifier" <no-reply@hackbaltimore.org>},
    :exception_recipients => ENV["EXCEPTION_EMAIL_ADDRESSES"].split(/,/)
  }
end
