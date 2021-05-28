class RegulationsDotGov::V4::Comment

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def posted_date
    if raw_attribute_value('postedDate')
      Time.parse(raw_attribute_value('postedDate'))
    end
  end

  def regulations_dot_gov_document_id
    raw_attributes['id']
  end


  private

  attr_reader :raw_attributes

  def raw_attribute_value(name)
    raw_attributes.dig('attributes', name)
  end

end
