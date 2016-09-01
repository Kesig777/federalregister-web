class SubscriptionDecorator < ApplicationDecorator
  decorates :subscription
  delegate_all

  def type
    mailing_list.type.split('::').last
  end

  def display_type
    type == "Document" ? "Document Subscription" : "Public Inspection Document Subscription"
  end

  def icon_class
    type == "Document" ? "document_subscription" : "pi_subscription"
  end

  def search_path
    case type
    when "Document"
      h.documents_search_path(search_params)
    when "PublicInspectionDocument"
      h.public_inspection_search_path(search_params)
    end
  end

  def search_params
    {conditions: mailing_list.parameters}
  end

  def sparkline_url
    url = case type
          when "Document"
            "/articles/search/activity/sparkline/weekly"
          when "PublicInspectionDocument"
            "/public-inspection/search/activity/sparkline/weekly"
          end

    chart_params = {:chart_options => {:chart_bg_color => 'F5F8F9'}}

    "#{url}?#{chart_params.to_query}&#{mailing_list.parameters.to_query}"
  end


  def delivery_count
    model.delivery_count || 0
  end

  def subscribed_on
    created_at
  end

  def last_delivered_on
    if last_delivered_at
      last_delivered_at
    else
      "No items have matched since subscription started"
    end
  end

  def comment
    if model.comment.present?
      @comment ||= CommentDecorator.decorate( model.comment )
    end
  end
end
