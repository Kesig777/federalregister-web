class CategoryStatisticsPresenter
    extend Memoist

    delegate :name, :identifier, to: :statistic_type
    attr_reader :statistic_type

    def initialize(statistic_type)
      @statistic_type = statistic_type
    end

    def years
      document_type_stats_csv[2].first
    end

    def title
      document_type_stats_csv.first.first.titlecase
    end

    def header_columns
      document_type_stats_csv[statistic_type.header_csv_index]
    end

    def table_rows
      document_type_stats_csv[(statistic_type.header_csv_index + 1)..-(statistic_type.footnote_count + 1)]
    end

    def footnotes
      document_type_stats_csv.last(statistic_type.footnote_count).map(&:first)
    end

    def csv_url
      if Rails.env.development?
        "https://fr2.criticaljuncture.org/api/v1/category_counts/#{statistic_type.identifier}.csv"
      else
        "#{Settings.services.fr.api_core.internal_base_url}/category_counts/#{statistic_type.identifier}.csv"
      end
    end


    private

    def document_type_stats_csv
      response = Faraday.get(csv_url)
      CSV.parse(response.body, encoding: 'UTF-8')
    end
    memoize :document_type_stats_csv

end
