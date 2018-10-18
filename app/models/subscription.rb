class Subscription < ApplicationModel
  attr_accessible :search_conditions, :search_type
  default_scope :conditions => { :environment => Rails.env }

  before_create :generate_token
  after_create :remove_from_bounce_list

  attr_accessor :search_conditions, :search_type

  belongs_to :mailing_list
  belongs_to :comment

  validates_presence_of :requesting_ip, :mailing_list, :environment

  def mailing_list_with_autobuilding
    if mailing_list_without_autobuilding.nil?
      klass = search_type == 'PublicInspectionDocument' ? MailingList::PublicInspectionDocument : MailingList::Document
      self.search_conditions ||= {}
      self.mailing_list = klass.find_by_parameters(search_conditions.to_json) || klass.new(:parameters => search_conditions)
    else
      mailing_list_without_autobuilding
    end
  end
  alias_method_chain :mailing_list, :autobuilding

  def self.not_delivered_on(date)
    scoped(:conditions => ["subscriptions.last_issue_delivered IS NULL OR subscriptions.last_issue_delivered < ?", date])
  end

  def public_inspection_search_possible?
    Search::PublicInspection.new(search_conditions).valid_search?
  end

  def to_param
    token
  end

  def user
    @user ||= User.find(user_id)
  end

  def active?
    unsubscribed_at.nil? && deleted_at.nil?
  end

  def unsubscribe!
    unless self.unsubscribed_at
      self.unsubscribed_at = Time.current
      self.save!
    end
  end
  alias_method :suspend!, :unsubscribe!

  def activate!
    self.unsubscribed_at = nil
    self.save!
  end


  private

  def remove_from_bounce_list
    begin
      SendgridClient.new.remove_from_bounce_list(user.email)
    rescue StandardError => e
      Honeybadger.notify(e)
    end
  end

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  def self.document_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::Document"}})
  end

  def self.pi_subscriptions
    scoped(:include => :mailing_list,
           :conditions => {:mailing_lists => {:type => "MailingList::PublicInspectionDocument"}})
  end
end
