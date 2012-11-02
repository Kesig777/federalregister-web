class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  
  def new
    @subscription = Subscription.new(params[:subscription])
    @subscription.search_type ||= 'Entry'
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])
    
    @subscription.requesting_ip = request.remote_ip
    @subscription.environment = Rails.env
    if @subscription.save
      redirect_to confirmation_sent_subscriptions_url
    else
      render :action => :new
    end
  end
  
  def confirmation_sent
  end
  
  def confirm
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.confirm!
    redirect_to confirmed_subscriptions_path(:type => @subscription.mailing_list.type)
  end
  
  def confirmed
  end
  
  def unsubscribe
    @subscription = Subscription.find_by_token!(params[:id])
  end
  
  def destroy
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.unsubscribe!
    redirect_to unsubscribed_subscriptions_url
  end
  
  def unsubscribed
  end
end
