#= require vendor
#= require old/application

#= require utilities/ajax_setup
#= require namespace

#= require handlebars_helpers
#= require storage.js
#= require analytics.js
#= require analytics/comments

#= require components
#= require fr_modal
#= require form_utils
#= require subscription
#= require user_session

#= require_tree ./components/comments/
#= require page_specific/comment_creation
#= require page_specific/comment_notifications

#= require_self

#= require utilities/tooltip
#= require folder_actions
#= require add_to_folder
#= require clippings
#= require subscription_filters
#= require tipsy
#= require article_page
#= require document_page
#= require public_inspection
#= require utility_bar

# Homepage
#= require home/home_section_preview_manager

#= require old/rss
#= require old/navigation

#= require scrollMonitor
#= require_tree ./documents

#= require search

# Namespaced JS Classes
#= require utilities/cj_tooltip
#= require utilities/modal
#= require utilities/element_scroller
#= require utilities/toggle
#= require utilities/list_item_filter
#= require utilities/list_item_sorter

# Instantiate and bind common application js items
#= require app
