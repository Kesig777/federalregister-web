class Section < ActiveHash::Base
   self.data = [
    {
      id: 1,
      title: 'Money',
      slug: 'money',
      icon: 'Coins-dollaralt'
    },
    {
      id: 2,
      title: 'Environment',
      slug: 'environment',
      icon: 'Eco'
    },
    {
      id: 3,
      title: 'World',
      slug: 'world',
      icon: 'globe'
    },
    {
      id: 4,
      title: 'Science & Technology',
      slug: 'science-and-technology',
      icon: 'Lab'
    },
    {
      id: 5,
      title: 'Business & Industry',
      slug: 'business-and-industry',
      icon: 'Factory'
    },
    {
      id: 6,
      title: 'Health & Public Welfare',
      slug: 'health-and-public-welfare',
      icon: 'Medicine'
    },
   ]

  def self.slugs
    all.map{|s| s.slug}
  end

  def to_param
    slug
  end

  def suggested_searches
    @suggested_searches ||= SuggestedSearch.search(
      conditions: {
        sections: Array(slug)
      }
    )[slug]
  end

  def new_documents_for(date)
    Document.search_metadata(
      new_documents_for_date_conditions(date)
    ).count
  end

  def documents_with_open_comment_periods_for(date)
    Document.search_metadata(
      documents_with_open_comment_periods_for_date_conditions(date)
    ).count
  end

  def new_documents_for_date_conditions(date)
    QueryConditions::DocumentConditions.
      published_on(date).
      deep_merge!(
        conditions: {
          sections: Array(slug)
        }
      )
  end

  def documents_with_open_comment_periods_for_date_conditions(date)
    QueryConditions::DocumentConditions.
      with_open_comment_periods_on(date).
      deep_merge!(
        conditions: {
          sections: Array(slug)
        }
      )
  end
end
