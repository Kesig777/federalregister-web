class Documents::EmailsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false

  def new
    @document = Document.find(params[:document_number])

    raise ActiveRecord::RecordNotFound unless @document

    @document_email = EntryEmail.new
    @document_email.document_number = @document.document_number
  end

  def create
    @document = Document.find(params[:document_number])
    @document_email = EntryEmail.new(document_email_params)
    @document_email.document_number = @document.document_number

    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || ''
    remote_ip = remote_ip.split(/\s*,\s*/).last
    @document_email.remote_ip = remote_ip

    if (!@document_email.requires_captcha? || verify_recaptcha(model: @document_email)) && @document_email.save
      render text: '<div class="flash-message success">Success! Your email will be sent momentarily.</div>', status: 200
    else
      render action: :new, status: 400
    end
  end

  private

  def document_email_params
    params.require(:entry_email).permit(
      :sender,
      :send_me_a_copy,
      :recipients,
      :message
    )
  end
end
