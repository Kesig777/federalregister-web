class EoCollection
  attr_reader :president, :year, :date_range

  FIELDS = [
    :citation,
    :document_number,
    :end_page,
    :executive_order_notes,
    :executive_order_number,
    :html_url,
    :pdf_url,
    :publication_date,
    :signing_date,
    :start_page,
    :title,
  ]

  def initialize(president, year, date_range=nil)
    @president = president
    @year = year
    @date_range ||= @president.year_ranges[@year]
  end

  def results
    @results ||= Document.search(
      QueryConditions::PresidentialDocumentConditions.presidential_documents(
        president,
        year,
        'executive_order'
      ).deep_merge!({
        conditions: {correction: 0},
        fields: FIELDS,
        order: 'executive_order_number',
        per_page: '1000'
      })
    ).map do |document|
      unless document.executive_order_number == 0
        DocumentDecorator.decorate(document)
      end
    end.compact.reverse
  end
  alias_method :executive_orders, :results

  def count
    results.count
  end

  def minimum_number
    results.last.executive_order_number
  end

  def maximum_number
    results.first.executive_order_number
  end
end
