class FrBox::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  include RouteBuilder::ReaderAidUrls

  attr_reader :options

  ATTRS = [
    :css_selector,
    :description,
    :stamp_icon,
    :title,
  ]

  def initialize(options)
    @options = options
  end

  def default_options(options={})
    {}
  end

  def background_seal?
    stamp_icon.present?
  end

  ATTRS.each do |attr|
    define_method attr do
      options[attr]
    end
  end
end
