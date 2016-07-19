require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::NonPrintedElements" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates the proper elements for PREAMB" do
    process <<-XML
      <PREAMB>
        Some text nodes and other content nodes
      </PREAMB>
    XML

    expect(html).to have_tag("span.preamble-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.preamble.unprinted-element.document-markup",
        with: {"data-text" => "Start Preamble"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.preamble-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.preamble.unprinted-element.document-markup",
        with: {"data-text" => "End Preamble"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for FURINF" do
    process <<-XML
      <FURINF>
        Some text nodes and other content nodes
      </FURINF>
    XML

    expect(html).to have_tag("span.further-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.further-info.unprinted-element.document-markup",
        with: {"data-text" => "Start Further Info"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.further-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.further-info.unprinted-element.document-markup",
        with: {"data-text" => "End Further Info"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper tooltip elements for APPENDIX in a REGTEXT block" do
    process <<-XML
      <REGTEXT>
        <APPENDIX>
          Some text nodes and other content nodes
        </APPENDIX>
      </REGTEXT>
    XML

    expect(html).to have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.appendix.unprinted-element.document-markup",
        with: {"data-text" => "Start Appendix"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.appendix.unprinted-element.document-markup",
        with: {"data-text" => "End Appendix"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "does not creates the tooltip elements for APPENDIX not in a REGTEXT block" do
    process <<-XML
      <APPENDIX>
        Some text nodes and other content nodes
      </APPENDIX>
    XML

    expect(html).to_not have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.appendix.unprinted-element.document-markup",
        with: {"data-text" => "Start Appendix"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to_not have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.appendix.unprinted-element.document-markup",
        with: {"data-text" => "End Appendix"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for SIG" do
    process <<-XML
      <SIG>
        Some text nodes and other content nodes
      </SIG>
    XML

    expect(html).to have_tag("span.signature-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.signature.unprinted-element.document-markup",
        with: {"data-text" => "Start Signature"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to have_tag("div.signature") do
      with_text /Some text nodes and other content nodes/
    end

    expect(html).to have_tag("span.signature-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.signature.unprinted-element.document-markup",
        with: {"data-text" => "End Signature"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for SUPLINF" do
    process <<-XML
      <SUPLINF>
        Some text nodes and other content nodes
      </SUPLINF>
    XML

    expect(html).to have_tag("span.supplemental-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.supplemental-info.unprinted-element.document-markup",
        with: {"data-text" => "Start Supplemental Information"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.supplemental-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.supplemental-info.unprinted-element.document-markup",
        with: {"data-text" => "End Supplemental Information"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for LSTSUB" do
    process <<-XML
      <LSTSUB>
        Some text nodes and other content nodes
      </LSTSUB>
    XML

    expect(html).to have_tag("span.list-of-subjects-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.list-of-subjects.unprinted-element.document-markup",
        with: {"data-text" => "Start List of Subjects"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.list-of-subjects-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.list-of-subjects.unprinted-element.document-markup",
        with: {"data-text" => "End List of Subjects"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for PART" do
    process <<-XML
      <PART>
        Some text nodes and other content nodes
      </PART>
    XML

    expect(html).to have_tag("span.part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.part.unprinted-element.document-markup",
        with: {"data-text" => "Start Part"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.part.unprinted-element.document-markup",
        with: {"data-text" => "End Part"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for AMDPAR" do
    process <<-XML
      <AMDPAR>
        Some text nodes and other content nodes
      </AMDPAR>
    XML

    expect(html).to have_tag("span.amend-part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.amend-part.unprinted-element.document-markup",
        with: {"data-text" => "Start Amendment Part"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.amend-part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.amend-part.unprinted-element.document-markup",
        with: {"data-text" => "End Amendment Part"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for AUTH" do
    process <<-XML
      <AUTH>
        Some text nodes and other content nodes
      </AUTH>
    XML

    expect(html).to have_tag("span.authority-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.authority.unprinted-element.document-markup",
        with: {"data-text" => "Start Authority"}
      with_tag "span.unprinted-element-border"
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.authority-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border"
      with_tag "span.authority.unprinted-element.document-markup",
        with: {"data-text" => "End Authority"}
      with_tag "span.unprinted-element-border"
    end
  end

  it "creates the proper elements for SUBPART" do
    process <<-XML
      <SUBPART>
        Some text nodes and other content nodes
      </SUBPART>
    XML

    expect(html).to have_tag("span.subpart-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.subpart.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-text" => "Start Sub-Part"}
      end
    end

    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.subpart-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.subpart.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-text" => "End Sub-Part"}
      end
    end
  end

end
