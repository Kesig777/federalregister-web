class SubscriptionMailer < ActionMailer::Base
  include SendGrid

  add_template_helper(MailerHelper)
  add_template_helper(BootstrapHelper)
  add_template_helper(FrBoxHelper)
  add_template_helper(DocumentIssueHelper)
  add_template_helper(IconHelper)

  default :from => "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def subscription_confirmation(subscription)
    @subscription = subscription
    @utility_links = []
    @highlights = EmailHighlight.highlights_with_selected(1, 'manage_subscriptions_via_my_fr')

    sendgrid_category "Subscription Confirmation"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription confirmation'

    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    ) do |format|
      format.text { render('subscription_confirmation') }
      format.html { Premailer.new( render('subscription_confirmation', :layout => "mailer/two_col_1_2"),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  def unsubscribe_notice(subscription)
    @subscription = subscription
    @utility_links = []
    @highlights = EmailHighlight.highlights_with_selected(1, 'manage_subscriptions_via_my_fr')

    sendgrid_category "Subscription Unsubscribe"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription unsubscribe'

    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    ) do |format|
      format.text { render('unsubscribe_notice') }
      format.html { Premailer.new( render('unsubscribe_notice', :layout => "mailer/two_col_1_2"),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  def public_inspection_document_mailing_list(date, results, mailing_list, subscriptions)
    @mailing_list = mailing_list

    @results = results
    results = results.group_by(&:filing_type)
    special_filing_results = results["special"]
    regular_filing_results = results["regular"]

    @presenter = PublicInspectionIssuePresenter.new(date)
    @special_filings_presenter = special_filing_results ? Mailers::PublicInspectionSpecialFilingsPresenter.new(date, special_filing_results) : nil
    @regular_filings_presenter = regular_filing_results ? Mailers::PublicInspectionRegularFilingsPresenter.new(date, regular_filing_results) : nil

    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")],
                      ["Unsubscribe from these results", unsubscribe_subscription_url('(((token)))')]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category "PI Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'pi subscription mailing list'

    mail(
      :subject => "[FR] #{mailing_list.title}",
      :to => 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    ) do |format|
      format.text { render('public_inspection_document_mailing_list') }
      format.html {
        Premailer.new(
          render('public_inspection_document_mailing_list', layout: "mailer/two_col_1_2"),
          with_html_string: true,
          warn_level: Premailer::Warnings::SAFE
        ).to_inline_css
      }
    end
  end

  def entry_mailing_list(date, mailing_list, results, subscriptions)
    @mailing_list = mailing_list
    @results = DocumentDecorator.decorate_collection(results.to_a)
    @presenter = Mailers::TableOfContentsPresenter.new(date, @results)

    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")],
                      ["Unsubscribe from these results", unsubscribe_subscription_url('(((token)))')]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category "Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription mailing list'

    mail(
      subject: "[FR] #{mailing_list.title}",
      to:  'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    ) do |format|
      format.text { render('entry_mailing_list') }
      format.html {
        Premailer.new(
          render('entry_mailing_list', layout: "mailer/two_col_1_2"),
          with_html_string: true,
          warn_level: Premailer::Warnings::SAFE
        ).to_inline_css
      }
    end

  end

  class Preview < MailView
    def subscription_confirmation
      subscription = Subscription.find(2)
      SubscriptionMailer.subscription_confirmation(subscription)
    end

    def unsubscribe_notice
      subscription = Subscription.find(2)
      SubscriptionMailer.unsubscribe_notice(subscription)
    end

    def entry_mailing_list
      date = '2016-07-22'
      mailing_list = MailingList.find(2)
      subscriptions = mailing_list.subscriptions
      results = mailing_list.send(:results_for_date, Date.parse(date) )
      SubscriptionMailer.entry_mailing_list(date, mailing_list, results, subscriptions)
    end

    def public_inspection_document_mailing_list
      date = '2016-07-22'
      mailing_list = MailingList.find(22251)
      subscriptions = mailing_list.subscriptions
      document_numbers = PublicInspectionDocument.available_on(date).map(&:document_number)
      results = mailing_list.send(:results_for_document_numbers, document_numbers)
      SubscriptionMailer.public_inspection_document_mailing_list(date, results, mailing_list, subscriptions)
    end
  end
end
