require File.dirname(__FILE__) + '/../spec_helper'

describe Hyperlinker do
  include RouteBuilder::Fr2Urls
  include Hyperlinker::Citation::UrlHelpers

  def hyperlink(text)
    Hyperlinker.perform(text)
  end

  def h(str)
    ERB::Util.html_escape(str)
  end

  describe 'adding links to HTML' do
    it 'should not interfere with existing links' do
      expect(hyperlink('<a href="#">10 CFR 100</a>')).to eq '<a href="#">10 CFR 100</a>'
    end

    it 'should not interfere with existing HTML but add its own links' do
      expect(hyperlink('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta 10 CFR 10 omega</em></p>')).to eq ('<p><a href="#">10 CFR 100</a> and (<em>hi</em>) <em>alpha</em> beta <a class="cfr external" href="' +  h(select_cfr_citation_path(Time.current.to_date, '10','10')) + '">10 CFR 10</a> omega</p>')
    end

    it "should ignore URLs within existing hyperlinks but add ones outside" do
      expect(hyperlink('<a href="http://www.example.com"><b>www.example.com</b></a> http://www.google.com')).to eql '<a href="http://www.example.com"><b>www.example.com</b></a> <a href="http://www.google.com">http://www.google.com</a>'
    end
  end
end
