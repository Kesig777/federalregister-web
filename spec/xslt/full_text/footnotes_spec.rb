require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Footnotes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "rendering the footnotes" do
    before :all do
      process <<-XML
        <FTNT>
          <P>
            <SU>1</SU>
            NCC, 2011. Broiler Industry Marketing Survey Report
          </P>
        </FTNT>
      XML
    end

    it "creates a header and appropriate footnotes div" do
      expect(html).to have_tag('h1#footnotes') do
        with_text /Footnotes/
      end

      expect(html).to have_tag('div.footnotes')
    end

    it "renders FTNT nodes as a div with the appropriate class and id" do
      expect(html).to have_tag('div.footnotes') do
        with_tag "div#footnote-1.footnote"
      end
    end

    it "renders FTNT nodes as a div with the proper content" do
      expect(html).to have_tag("div#footnote-1.footnote") do
        with_text /1.\s+NCC, 2011. Broiler Industry Marketing Survey Report/
      end
    end

    it "adds a link back to the original footnote reference in the document" do
      expect(html).to have_tag("a.back", with: {href: '#citation-1'}) do
        with_text /Back to Context/
      end
    end
  end

  it "moves the footnotes to the bottom of the document" do
    process <<-XML
      <P>
        <SU>1</SU>
        <FTREF/>
      </P>
      <FTNT>
        <P>
          <SU>1</SU>
          Footnote 1 text
        </P>
      </FTNT>
      <P>
        <SU>2</SU>
        <FTREF/>
      </P>
      <FTNT>
        <P>
          <SU>2</SU>
          Footnote 2 text
        </P>
      </FTNT>
    XML

    expect_equivalent <<-HTML
      <p id="p-1" data-page="1000">
        <sup id="citation-1">
          [<a class="footnote-reference" href="#footnote-1">1</a>]
        </sup>
      </p>
      <p id="p-3" data-page="1000">
        <sup id="citation-2">
          [<a class="footnote-reference" href="#footnote-2">2</a>]
        </sup>
      </p>
      <h1 id="footnotes">Footnotes</h1>
      <div class="footnotes">
        <div class="footnote" id="footnote-1">
          <p id="p-2" data-page="1000">
            1. Footnote 1 text
          </p>
          <a class="back" href="#citation-1"> Back to Context </a>
        </div>
        <div class="footnote" id="footnote-2">
          <p id="p-4" data-page="1000">
            2. Footnote 2 text
          </p>
          <a class="back" href="#citation-2"> Back to Context </a>
        </div>
      </div>
    HTML
  end


  context "rendering the footnote references in the body of the document" do
    context "when footnotes are marked up as <SU> tags" do
      before :each do
        process <<-XML
          <P>
            <SU>2</SU>
            <FTREF/>
          </P>
        XML
      end

      it "creates a superscript" do
        expect(html).to have_tag("sup#citation-2", count: 1)
      end

      it "creates an internal link to the footnote in the text" do
        expect(html).to have_tag("sup") do
          with_tag "a.footnote-reference", with: {href: '#footnote-2'} do
            with_text /2/
          end
        end
      end
    end

    context "when footnotes are marked up as <E T='51'> tags" do
      it "properly converts multiple footnotes in a superscript tag with multiple links" do
        process <<-XML
          <P>
            MitraClip System meets the substantial clinical improvement criterion based on clinical studies
            <E T="51">4 5 6 7</E>
            <FTREF/>
            that have consistently...
          </P>
        XML

        expect_equivalent <<-HTML
          <p id="p-1" data-page="1000">
            MitraClip System meets the substantial clinical improvement criterion 
            based on clinical studies[<sup><a class="footnote-reference" href="#footnote-4">4</a>
            <a class="footnote-reference" href="#footnote-5">5</a>
            <a class="footnote-reference" href="#footnote-6">6</a>
            <a class="footnote-reference" href="#footnote-7">7</a></sup>]
            that have consistently...
          </p>
        HTML
      end

      it "properly converts a single footnote into a superscript tag" do
        process <<-XML
          <HD SOURCE="HD1">
            II. Fees for FY 2015
            <E T="51">1</E>
            <FTREF/>
          </HD>
        XML

        expect_equivalent <<-HTML
          <h2 id="h-1">
            II. Fees for FY 2015[<sup><a class="footnote-reference" href="#footnote-1">1</a></sup>]
          </h2>
        HTML
      end
    end
  end
end

