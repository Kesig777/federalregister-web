# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
Rails.application.config.assets.precompile += %w(
  vendor.js
  admin/vendor.js
  search.js
  tender_widget_custom.js

  page_specific/agencies.js
  page_specific/agency_logo.js
  page_specific/clippings.js
  page_specific/clipping_filters.js
  page_specific/comment_creation.js
  page_specific/comment_notifications.js
  page_specific/homepage.js
  page_specific/search.js
  page_specific/sections.js
  page_specific/subscription_filters.js
  page_specific/topics.js

  admin/highlighted_documents.js
  utilities/modal.js

  print.css
  vendor.css

  mailers/comment_mailer.css
  mailers/common.css
  mailers/fr_mailer.css
  mailers/subscription_mailer.css

  *.eot
  *.svg
  *.ttf
  *.woff

  admin/highlighted_documents.js
  utilities/modal.js


  clippy.swf

  Barack_Obama_sm.jpg
  Bill_Clinton_sm.jpg
  George_W_Bush_sm.jpg
  Donald_Trump_sm.jpg

  doc_preview.png

  official_masthead.png
  official_masthead.svg
  public_inspection_masthead.png
  public_inspection_masthead.svg
  reader_aids_masthead.png
  reader_aids_masthead.svg

  blue_header_bg.png
  red_header_bg.png

  search.png
  search.svg

  regulations_dot_gov_logo.png
  regulations_dot_gov_logo_sidebar.png
)
