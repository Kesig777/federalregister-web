require 'spec_helper'

describe SessionsController do
  # create our own abtract controller with action for testing
  controller do
    def new
      persist_user_data
    end
  end

  before(:each) do
    User.current = nil
  end

  def authenticated_session
    {
      user_details: {
        "sub"             => 9999,
        "email"           => 'john_doe@example.com',
        "email_confirmed" => true
      }
    }
  end

  describe "Clippings" do
    before(:each) do
      allow_any_instance_of(Clipping).to receive(:document).and_return(double)
    end

    it "persists a document if a document number is saved in the cookie" do
      cookies[:document_numbers] = [{'2014-13781' => ['my-clippings']}].to_json
      get :new, nil, authenticated_session

      clipping = Clipping.first

      {
        document_number: '2014-13781',
        user_id: authenticated_session[:user_details]["sub"],
        folder_id: nil
      }.each do |attribute, value|
        expect(clipping[attribute]).to eq(value)
      end
    end
  end

  describe "Comments" do
    before(:each) do
      validation_methods = [
        :send_to_regulations_dot_gov,
        :persist_comment_data,
      ]
      validation_methods.each do |validation_method|
        allow_any_instance_of(Clipping).to receive(validation_method).and_return(true)
      end
    end

    let!(:comment) do
      create(:comment_skipped_validations,
        comment_tracking_number: 123,
      )
    end

    it "if a comment tracking number and secret are stored in the session, and a matching comment exists in the database, the CommentMailer is called" do
      allow(Ecfr::UserEmailResultSet).to receive(:get_user_emails).and_return(values: ['john_doe@example.com'])
      CommentMailer.stub_chain(:comment_copy, :deliver)
      expect(CommentMailer).to receive(:comment_copy)

      get :new, nil, authenticated_session.merge(
        comment_tracking_number: 123,
        comment_secret: 'abcd1234',
      )
    end

    it "if a comment cannot be located the UserDataPersistor does not fail" do
      expect {
        get :new, nil, authenticated_session.merge(
          comment_tracking_number:        77777,
          comment_secret:                 88888,
          followup_document_notification: "1"
        )
      }.to_not raise_error
    end
  end

  describe "Subscriptions" do
    it "associates a subscription with the current user" do
      subscription = FactoryGirl.create(
        :subscription,
        token:        "abcd1234",
        user_id:      nil
      )
      get :new, nil, authenticated_session.merge(
        subscription_token: subscription.token
      )

      subscription.reload
      expect(subscription.user_id).to eq(authenticated_session[:user_details]["sub"])
    end
  end
end
