#= require jquery_ujs
#= require bootstrap/dropdown
#= require jquery.clippy.min
#= require_self
#= require utilities/tooltip
#= require add_to_folder
#= require clippings
#= require clipping_filters
#= require subscription_filters
#= require tipsy
#= require article_page
#= require document_page
#= require public_inspection
#= require utility_bar
#= require home_carousel
#= require old/agency_list
#= require old/search
#= require old/rss
#= require_tree ./documents

$(document).ready ()->
  $('.clippy').clippy({
    keep_text: true,
    clippy_path: '/assets/clippy.swf'
  })
