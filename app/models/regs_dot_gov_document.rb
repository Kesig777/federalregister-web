class RegsDotGovDocument < FederalRegister::Base
  add_attribute :allow_late_comments, :comment_count, :comment_end_date, :comment_start_date, :comment_url, :docket, :id, :regulations_dot_gov_open_for_comment, :updated_at

  def once_accepted_comments?
    comment_start_date
  end

  def accepting_comments?
    allow_late_comments || (regulations_dot_gov_open_for_comment && comment_end_date_unelapsed?)
  end

  def updated_at
    if attributes["updated_at"]
      Time.parse(attributes["updated_at"])
    end
  end

  def non_utc_comment_end_date
    # The regs.gov commentEndDate attribute is provided as a UTC timestamp (which means it is stored as the next day in the DB)
    return unless comment_end_date

    Date.parse(comment_end_date) - 1.day
  end

  private

  def comment_end_date_unelapsed?
    if comment_end_date
      Date.parse(comment_end_date) > Date.current
    else
      true
    end
  end

end
