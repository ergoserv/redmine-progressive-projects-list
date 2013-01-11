module Progressive::ProjectDecorator
  def issues_closed_percent
    if issues.count == 0
      0
    else
      issues_progress(false)
    end
  end

  # Cloned from Version#estimated_average
  def estimated_average
    if @estimated_average.nil?
      average = issues.average(:estimated_hours).to_f
      if average == 0
        average = 1
      end
      @estimated_average = average
    end
    @estimated_average
  end

  # Cloned from Version#issues_progress(open)
  def issues_progress(open)
    @issues_progress ||= {}
    @issues_progress[open] ||= begin
      progress = 0
      if issues.count > 0
        ratio = open ? 'done_ratio' : 100

        done = issues.sum("COALESCE(estimated_hours, #{estimated_average}) * #{ratio}",
                                  :joins => :status,
                                  :conditions => ["#{IssueStatus.table_name}.is_closed = ?", !open]).to_f
        progress = done / (estimated_average * issues.count)
      end
      progress
    end
  end

  # Cloned from Version#completed_pourcent
  def issues_completed_percent
    if issues.count == 0
      0
    elsif issues.open.count == 0
      100
    else
      issues_progress(false) + issues_progress(true)
    end
  end
end
