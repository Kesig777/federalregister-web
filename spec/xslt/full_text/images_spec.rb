require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Images" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "with embedded images present" do

    it "renders the basic markup for an embedded image" do
      process <<-XML
        <GPH DEEP="640" SPAN="3">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag("p.document-graphic") do
        with_tag 'a.document-graphic-link' do
          with_tag 'img.document-graphic-image'
        end
      end
    end

    context "all embedded images" do
      it "renders the proper attributes for a link in the embedded image" do
        process <<-XML
          <GPH DEEP="640" SPAN="3">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag 'a', with: {
          class: 'document-graphic-link',
          id: 'g-1'
        }
      end

      it "renders the proper attributes for the img tag in the embedded image" do
        process <<-XML
          <GPH DEEP="640" SPAN="3">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag 'img', with: {
          class: 'document-graphic-image full'
        }
      end

      it "renders the proper data attributes for width when @SPAN=3" do
        process <<-XML
          <GPH DEEP="640" SPAN="3">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag('p.document-graphic') do
          with_tag(
            'a.document-graphic-link',
            with: {
              'data-col-width' => '3',
              'data-height' => '640'
            }
          ) do
            with_tag 'img.document-graphic-image.full'
          end
        end
      end

      it "renders the proper data attributes for width when @SPAN=1" do
        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag('p.document-graphic') do
          with_tag(
            'a.document-graphic-link',
            with: {
              'data-col-width' => '1',
              'data-height' => '320'
            }
          ) do
            with_tag 'img.document-graphic-image.small'
          end
        end
      end

      it "render the proper inline style for width" do
        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag('p.document-graphic') do
          with_tag(
            'img.document-graphic-image',
            with: {
              'style' => 'max-height: 412px'
            }
          )
        end
      end
    end

    context "presidential signatures" do

      it "adds the proper url to the link tag" do
        allow(ImageVariant).to receive(:find).and_return([ImageVariant.new("url" => "https://example.com/OB%231/original_size.png")])

        process <<-XML
          <GPH DEEP="640" SPAN="3">
            <GID>OB#1.EPS</GID>
          </GPH>
        XML

        expect(html).to have_tag 'a', with: {
          href: "https://example.com/OB%231/original_size.png"
        }
      end

      it "adds the proper source url to the img tag" do
        allow(ImageVariant).to receive(:find).and_return([ImageVariant.new("url" => "https://example.com/OB%231/original_size.png")])

        process <<-XML
          <GPH DEEP="640" SPAN="3">
            <GID>OB#1.EPS</GID>
          </GPH>
        XML

        expect(html).to have_tag 'img', with: {
          src: "https://example.com/OB%231/original_size.png"
        }
      end
    end

    context "xml identifier has corresponding image present in api" do
      it "adds the proper url to the link tag" do
        allow(ImageVariant).to receive(:find).and_return([ImageVariant.new("url" => "https://example.com/EP01MY09.017/EP01MY09.017_original_size.png")])

        process <<-XML
          <GPH DEEP="640" SPAN="3">
          <GID>EP01MY09.017</GID>
          </GPH>
        XML

        expect(html).to have_tag 'a', with: {
          href: "https://example.com/EP01MY09.017/EP01MY09.017_original_size.png"
        }
      end

      it "adds the proper source url to the img tag" do
        allow(ImageVariant).to receive(:find).and_return([ImageVariant.new("url" => "https://example.com/EP01MY09.018/EP01MY09.018_original_size.png")])

        process <<-XML
          <GPH DEEP="640" SPAN="3">
          <GID>EP01MY09.018</GID>
          </GPH>
        XML

        expect(html).to have_tag 'img', with: {
          src: "https://example.com/EP01MY09.018/EP01MY09.018_original_size.png"
        }
      end

      it "does not notify honeybadger" do
        allow(ImageVariant).to receive(:find).and_return([ImageVariant.new("url" => "https://example.com/EP01MY09.018/EP01MY09.018_original_size.png")])

        allow(Honeybadger).to receive(:notify)

        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP01MY09.018</GID>
          </GPH>
        XML

        expect(Honeybadger).to_not have_received(:notify)
      end
    end

    context "xml identifier does not have corresponding image present in api" do
      it "notifies honeybadger" do
        allow(ImageVariant).to receive(:find).and_raise(FederalRegister::Client::RecordNotFound)
        allow(Honeybadger).to receive(:notify)

        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(Honeybadger).to have_received(:notify)
      end

      # The stub url will potentially change in time - but we want to attempt
      # to get the proper url even if the images isn't yet processed and available
      # on the document in the api. In many cases this means we won't have to reprocess
      # the xml-> for the image to appear.
      it "adds a stub url (what we currently expect the url to be)" do
        allow(ImageVariant).to receive(:find).and_raise(FederalRegister::Client::RecordNotFound)
        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP01MY09.019</GID>
          </GPH>
        XML

        expect(html).to have_tag 'a', with: {
          href: "https://#{Settings.s3_buckets.image_variants}/EP01MY09.019/EP01MY09.019_original_size.png"
        }

        expect(html).to have_tag 'img', with: {
          src: "https://#{Settings.s3_buckets.image_variants}/EP01MY09.019/EP01MY09.019_original_size.png"
        }
      end
    end
  end
end
