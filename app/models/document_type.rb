class DocumentType
  attr_reader :type, :slug

  def initialize(type)
    @type = type
  end

  def identifier
    @identifier ||= case type
    when 'Rule'
      'rule'
    when 'Proposed Rule'
      'proposed_rule'
    when 'Notice'
      'notice'
    when 'Presidential Document'
      'presidential_document'
    when 'Uncategorized Document'
      'uncategorized'
    when 'Sunshine Act Document'
      'notice'
    when 'Correction'
      'correct'
    when 'Administrative Order' #NOTE: Only used by the Table of Contents when GPO groups by memorandum, determination, etc.
      'administrative_order'
    end
  end

  def granule_class
    @granule_class ||= case type
      when "Rule"
        "RULE"
      when "Proposed Rule"
        "PRORULE"
      when "Notice"
        "NOTICE"
      when "Presidential Document"
        "PRESDOCU"
      when "Correction"
        "CORRECT"
      when "Uncategorized Document"
        "UNKNOWN"
      when "Sunshine Act Document"
        "SUNSHINE"
    end
  end

  def display_type
    type.
      split(" ").
      map(&:capitalize).
      join(" ")
  end

  def icon_wrapper_class(size=nil)
    "rule_type doc_#{identifier.downcase} #{size}"
  end

  def icon_class
    "icon-fr2 icon-doctype icon-fr2-#{identifier.downcase}"
  end
end
