require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::PrintedPage" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "uses the first page when there is no current page" do
    process <<-XML
      <P>
        Paragraph on the first printed page of the document.
      </P>
    XML

    expect(html).to have_tag("p", with: {'data-page' => '1000'})
  end

  it "uses the current page when there is a page defined" do
    process <<-XML
      <PRTPAGE P="1001"/>
      <P>
        Paragraph on the second printed page of the document.
      </P>
      <PRTPAGE P="1002"/>
      <P>
        Paragraph on the third printed page of the document.
      </P>
    XML

    expect(html).to have_tag("p", with: {'data-page' => '1001'})
    expect(html).to have_tag("p", with: {'data-page' => '1002'})
  end
end
