module SubscriptionHelper

  def status_for_subscription(subscription)
    [ content_tag(:dt, 'Status:', :class => subscription.active? ? 'unsubscribe_link' : 'resubscribe_link'),
      content_tag(:dd) do
        content_tag(:span, subscription.active? ? 'active' : 'inactive', :class =>  subscription.active? ? 'active' : 'inactive')
      end
    ].join("\n").html_safe
  end

  def actions_for_subscription(subscription)
    [ content_tag(:dt, 'Actions:', :class => subscription.active? ? 'unsubscribe_link' : 'resubscribe_link'),
      content_tag(:dd) do
        if subscription.active?
          link_to("unsubscribe", subscription_path(subscription), :class => 'unsubscribe')
        else
          link_to("resubscribe", confirm_subscription_path(subscription), :class => 'resubscribe')
        end
      end
    ].join("\n").html_safe
  end

  def subscribe_box(search_conditions={}, options={})
    render partial: 'components/subscribe_box', locals: {
      options: options,
      search_conditions: search_conditions
    }
  end

  def subscribe_link(search_conditions={}, options={})
    if options[:custom_path]
      path = options[:custom_path]
    else
      path = ''
    end

    link_to(path, class: "subscription subscription_action #{options[:class]} #{'rss-only' if options[:rss_only]}") do
      "#{fr_icon('message') unless options[:rss_only]} #{fr_icon('rss')} Subscribe".html_safe
    end
  end
end
