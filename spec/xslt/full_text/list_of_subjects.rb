require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::ListOfSubjects" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates list items for each term in the subject list" do
    process <<-XML
      <LSTSUB>
        <HD SOURCE="HED">List of Subjects in 9 CFR Part 78</HD>
        <P>Animal diseases, Bison, Cattle, Hogs, Quarantine, Reporting and recordkeeping requirements, Transportation.</P>
      </LSTSUB>
    XML

    expect_equivalent <<-HTML

    HTML
  end
end
