class DocumentDecorator < ApplicationDecorator
  delegate_all

  include RouteBuilder::ExternalUrls

  include DocumentDecorator::Shared

  include DocumentDecorator::Agencies
  include DocumentDecorator::Clippings
  include DocumentDecorator::Comments
  include DocumentDecorator::Corrections
  include DocumentDecorator::GovernmentPublishingOffice
  include DocumentDecorator::Officialness
  include DocumentDecorator::PresidentialDoc
  include DocumentDecorator::RegulationsDotGovInfo
  include DocumentDecorator::PresidentialDoc

  def slug
    html_url.split('/').last
  end

  def http_abstract_html_url
    # RW: Fix this when upgrading varnish
    abstract_html_url.
      gsub("https", "http")
  end

  def http_body_html_url
    uri = body_html_uri
    uri.scheme = "http"
    uri.to_s
  end

  def internal_body_html_url
    uri = body_html_uri
    internal_uri = URI.parse(
      Settings.services.fr.web.internal_base_url
    )

    uri.hostname = internal_uri.hostname
    uri.path = uri.path.prepend(internal_uri.path)
    uri.port = internal_uri.port
    uri.scheme = internal_uri.scheme
    uri.to_s
  end

  def body_html_uri
    URI.parse(body_html_url)
  end

  # Page Count/Range methods
  def start_page?
    start_page.present? && start_page != 0
  end

  def end_page?
    end_page.present?
  end

  def page_range
    if start_page? && end_page?
      end_page != start_page ? "#{start_page}-#{end_page}" : start_page
    else
      nil
    end
  end

  def pages
    if start_page? && end_page?
      end_page - start_page + 1
    else
      'NA'
    end
  end

  def formatted_cfr_references
    cfr_references.uniq.map do |cfr|
      str = ["#{cfr["title"]} CFR"]

      if cfr["chapter"].present?
        str << "chapter #{h.number_to_roman(cfr["chapter"])}"
      else
        str << cfr["part"]
      end
      str = str.join(' ')

      if cfr["citation_url"].present?
        h.link_to str, cfr["citation_url"]
      else
        str
      end
    end
  end

  def full_text_available?
    full_text_xml_url.present?
  end

  def pdf_available?
    pdf_url.present?
  end

  def mods_available?
    mods_url.present?
  end

  def public_inspection_document?
    object.class == PublicInspectionDocument
  end

  def effective_date
    effective_on
  end

  def citation_available?
    start_page?
  end

  def comments_close_date
    comments_close_on
  end

  def metadata_description
    return @document_metadata_description if @document_metadata_description

    description = "#{type.with_indefinite_article(true)} by " +
      content_tag(:span, agency_name_sentence, class: "agencies") +
      " on " +
      h.link_to(publication_date, h.document_issue_path(model))

    @document_metadata_description = description.html_safe
  end

  def citation_vol
    return unless citation_available?
    citation.split('FR').first().strip
  end

  def participating_agency?
    participating_agency_acronyms = Agency.participating_agency_acronyms

    agencies.any? do |agency|
      begin
        agency = Agency.find(agency.slug)
      rescue FederalRegister::Client::ResponseError => error
        Honeybadger.notify(error)
        agency = nil
      end

      if agency
        participating_agency_acronyms.include? agency.short_name
      end
    end
  end

  def table_of_contents_sorting_algorithm
    lambda {|doc| [doc.start_page, doc.end_page, doc.document_number] }
  end

  def google_analytics_data_expected?
    # GA data is provided on a delay of 24-48 hours
    publication_date != Date.current
  end
end
