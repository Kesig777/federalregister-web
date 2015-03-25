module XsltTestHelper
  require 'nokogiri'
  require 'xslt_transform'
  require 'action_controller'
  require 'pry'

  def expect_equivalent(expected_output)
    expect(
      XsltTransform.standardized_html(@html.to_xml)
    ).to eql(
      XsltTransform.standardized_html(expected_output)
    )
  end
end

# stub rails root so we can run tests without loading the whole environment
class Rails
  def self.root
     File.expand_path(File.join(__FILE__, '../../../'))
  end
end

