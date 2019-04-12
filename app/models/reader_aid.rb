class ReaderAid
  SECTIONS = {
    'office-of-the-federal-register-blog'=> {
      title: 'Office of the Federal Register Blog',
      icon_class: 'quote',
      type: 'posts',
      show_authorship: true,
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'using-federalregister-gov' => {
      title: 'Using FederalRegister.Gov',
      icon_class: 'help',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
    'understanding-the-federal-register' => {
      title: 'Understanding the Federal Register',
      icon_class: 'lightbulb-active',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
    'recent-updates' => {
      title: 'Recent Site Updates',
      icon_class: 'pc',
      type: 'posts',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'videos-tutorials' => {
      title: 'Videos & Tutorials',
      icon_class: 'movie',
      type: 'pages',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'developer-resources' => {
      title: 'Developer Resources',
      icon_class: 'tools',
      type: 'pages',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'government-policy-and-ofr-procedures' => {
      title: 'Government Policy and OFR Procedures',
      icon_class: 'legal',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
    'congressional-review' => {
      title: 'Congressional Review',
      icon_class: 'government',
      type: 'pages',
      index_settings: {
        display_count: 2,
        columns: 1
      }
    },
  }

  INTERACTIVE_PAGES = {
    'utilizing-complex-search-terms' => {
      template: 'search/documents/help',
    },
    'table-of-effective-dates-time-periods' => {
      template: 'reader_aids/table_of_effective_dates_time_periods',
      auxillary_presenter: Proc.new do
        publication_date = Date.parse(DocumentIssue.current.slug)
        EffectiveDatesPresenter.new(
          start_date: publication_date,
          end_date:   publication_date.advance(days: 90)
        )
      end
    }
  }

  def self.interactive_page?(slug)
    INTERACTIVE_PAGES.keys.include?(slug)
  end

  def self.template_for(slug)
    INTERACTIVE_PAGES[slug][:template]
  end

  def self.auxillary_presenter_for(slug)
    INTERACTIVE_PAGES[slug][:auxillary_presenter].call
  end
end
