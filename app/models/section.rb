class Section < ActiveHash::Base
   self.data = [
    {id: 1, title: 'Money', slug: 'money'},
    {id: 2, title: 'Environment', slug: 'environment'},
    {id: 3, title: 'World', slug: 'world'},
    {id: 4, title: 'Science and Technology', slug: 'science-and-technology'},
    {id: 5, title: 'Business and Industry', slug: 'business-and-industry'},
    {id: 6, title: 'Health and Public Welfare', slug: 'health-and-public-welfare'},
   ]

  def self.slugs
    all.map{|s| s.slug}
  end

  def to_param
    slug
  end
end
