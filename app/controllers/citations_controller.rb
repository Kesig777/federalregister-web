class CitationsController < ApplicationController
  skip_before_action :authenticate_user!

  CFR_REGEXP = /(\d+)-CFR-(\d+)(?:\.(\d+))?/

  def cfr
    title, part, section = params[:citation].match(CFR_REGEXP)[1..3]

    cfr_reference = "#{title} CFR #{part}#{".#{section}" if section.present?}"
    redirect_to "https://www.ecfr.gov/cfr-reference?#{{cfr: {reference: cfr_reference}}.to_query}"
  end

  def fr
    @volume, @page = params[:volume], params[:page]
    @fr_archives_citation = FrArchivesCitation.new(@volume, @page)

    search = SearchPresenter::Document.new(conditions: {term: "#{@volume} FR #{@page}"}).search
    document_numbers = search.search_details.suggestions.
      select{|s| s.respond_to?(:document_numbers)}.
      map(&:document_numbers).
      flatten

    case document_numbers.size
        when 0
      # none found
    when 1
      redirect_to short_document_path(document_numbers.first)
    else
      @documents = DocumentDecorator.decorate_collection Document.find_all(document_numbers)
    end
  end

  def eo
    @eo_number = params[:eo_number]

    result_set = FederalRegister::Document.
      search(
        :conditions => {"executive_order_numbers" => [params[:eo_number]]},
        "fields" => ["executive_order_number","citation", "document_number"]
      )

    document_numbers = result_set.map(&:document_number).compact
    citations = result_set.map(&:citation).compact
    if document_numbers.present?
      redirect_to short_document_path(document_numbers.first)
    elsif citations.present?
      @fr_archives_citation = lookup_fr_archives_citation(citations.first)
      render :eo, status: (@fr_archives_citation.pdf_url ? 200 : 404)
    else
      render :eo, status: 404
    end
  end

  private

  def lookup_fr_archives_citation(citation) #eg 50 FR 499
    volume = citation.match(/(\d+) FR/)[1]
    page   = citation.match(/FR (\d+)/)[1]
    FrArchivesCitation.new(volume, page)
  end
end
