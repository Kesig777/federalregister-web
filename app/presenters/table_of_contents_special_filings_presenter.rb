class TableOfContentsSpecialFilingsPresenter < TableOfContentsPresenter

  def initialize(date)
    super
  end

  def url
    "#{Settings.federal_register.base_uri}/public_inspection_issues/json/#{date.strftime('%Y/%m/%d')}/special_filing.json"
  end

  def document_partial
    'public_inspection_document_issues/document_details.html.erb'
  end

  def documents
    @special_filings_data ||= FederalRegister::PublicInspectionDocument.search(query_conditions_special_filings.
      merge(per_page: 1000,
            fields: ['pdf_url','pdf_file_size','num_pages','document_number',
                     'html_url','filed_at','docket_numbers','publication_date']
      )
    )
  end

  private

  def query_conditions_special_filings
    {
      conditions: {
        available_on: date.to_date,
        special_filing: 1
      }
    }
  end

end
