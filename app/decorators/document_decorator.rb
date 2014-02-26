class DocumentDecorator < ApplicationDecorator
  delegate_all

  def agency_names(options = {})
    autolink = true unless options[:no_links]

    if agencies.present?
      agencies = model.agencies.map{|a| "the #{h.link_to_if autolink, a.name, a.url}" }
    else
      agencies = model.agencies.map(&:name)
    end

    agencies.to_sentence.html_safe
  end

  def presidential_document?
    type == "Presidential Document"
  end

  def start_page?
    start_page.present? && start_page != 0
  end

  # Tuesday, December 17th, 2013
  def formal_publication_date
    publication_date.to_s(:formal)
  end

  # Dec 17th, 2013
  def shorter_ordinal_signing_date
    signing_date.to_s(:shorter_ordinal)
  end

  def page_range
    page = start_page
    page = "#{page}-#{end_page}" if end_page != start_page
  end

  def length
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
  end

  def formatted_cfr_references
    cfr_references.map do |cfr|
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

  def possible_regulations_dot_gov_comments?
    regulations_dot_gov_info && (comments_close_on.present? || has_comments?)
  end

  def has_comments?
    regulations_dot_gov_info && regulations_dot_gov_info['comments_count'] > 0
  end

  def accepting_comments?
    document_comment_period_open? || regulations_dot_gov_accepting_comments?
  end

  def document_comment_period_open?
    comments_close_on.present? && comments_close_on >= Time.current.to_date
  end

  # occasionally comment periods are extended on regulations.gov past the
  # originally published date in the document
  def regulations_dot_gov_accepting_comments?
    comment_url.present? && publication_date.to_time > 4.months.ago
  end

  def has_full_text?
    full_text_xml_url.present?
  end

  def formal_comment_link
    link_text = "Submit a formal comment"

    if comment_url.present?
      href = comment_url
      options = { target: '_blank', :'data-comment' => 1}
    else
      href = '#addresses'
      options = {}
    end

    h.link_to link_text, href, {id: 'start_comment', class: 'button formal_comment'}.merge(options)
  end

  def comment_link
    link_text = "Submit a public comment on this document"
    href = comment_url.present? ? comment_url : '#addresses'

    h.link_to link_text, href
  end

  def corrections?
    correction_of.present? || corrections.present?
  end

  def republication?
    document_number =~ /^R/
  end

  def correction_of_document
    return @doc if @doc

    doc_num = correction_of.split('documents/').last.split('.').first
    @doc = DocumentDecorator.decorate(FederalRegister::Document.find(doc_num, fields: ["html_url", "publication_date"]))
  end

  def corrected_documents
    return @corrected_documents if @corrected_documents

    @corrected_documents = corrections.map do |correction|
      doc_num = correction.split('documents/').last.split('.').first
      DocumentDecorator.decorate(FederalRegister::Document.find(doc_num, fields: ["document_number", "html_url", "publication_date"]))
    end
  end
end
