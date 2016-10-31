class WpApi::Post < WpApi::Content
  def path(section_identifier='office-of-the-federal-register-blog')
    link.gsub('/blog/', "/reader-aids/#{section_identifier}/")
  end

  def url(section_identifier='office-of-the-federal-register-blog')
    path(section_identifier)
  end

end
