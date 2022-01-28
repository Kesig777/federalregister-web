class FRMailer < ActionMailer::Base
  include SendGrid

  helper(MailerHelper)

  layout "mailer/two_col_1_2"

  default :from => "My Federal Register <noreply@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def generic_notification(emails, subject, html_content, text_content, category)
    @html_content = html_content
    @text_content = text_content
    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category category
    sendgrid_recipients emails
    sendgrid_substitute "(((email)))", emails
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => category

    mail(
      :from => "Federal Register <noreply@mail.federalregister.gov>",
      :subject => subject,
      :to => 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    ) do |format|
      format.text { render('generic_notification') }
      format.html { render('generic_notification') }
    end
  end

  class Preview < MailView

    def generic_notification
      emails = %w(name@example.com)
      email_notification = EmailNotification.find('subscription_management_my_fr_accounts')
      FRMailer.generic_notification(users, email_notification.subject, email_notification.html_content, email_notification.text_content, email_notification.category)
    end
  end

end
