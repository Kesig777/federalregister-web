module NavigationBarFacetHelper
  def comment_period_closing_count
    FederalRegister::Article.search_metadata(comment_period_closing_conditions).count
  end

  def publication_date_conditions
    # RW: @issue.publication_date
    {
      :conditions => {
        :publication_date => {:gte => Date.current - 1.week}
      }.merge(facet_conditions)
    }
  end


  def comment_period_closing_conditions
    {
      :conditions => {
        :comment_date => {
          :gte => (Date.current).to_s(:year_month_day),
          :lte => 1.week.from_now.to_date.to_s(:year_month_day)
        }
      }.merge(facet_conditions)
    }
  end

  def entry_counts_since(range_type)
    date = case range_type
      when 'week'
        1.week.ago
      when 'month'
        1.month.ago
      when 'quarter'
        3.months.ago
      when 'year'
        1.year.ago
      end

    FederalRegister::Article.search_metadata(
      :conditions => {
        :publication_date => {
          :gte => date.to_s(:year_month_day)
        }
      }.merge(facet_conditions)
    ).count
  end
end
