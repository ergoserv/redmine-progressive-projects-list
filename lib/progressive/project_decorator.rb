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

        done = issues.joins(:status).where("#{IssueStatus.table_name}.is_closed=?", !open)
                     .sum("COALESCE(CASE WHEN estimated_hours > 0 THEN estimated_hours ELSE NULL END, #{estimated_average}) * #{ratio}").to_f
        progress = done / (estimated_average * issues.count)
      end
      progress
    end
  end

  # Cloned from Version#completed_percent
  def issues_completed_percent
    if issues.count == 0
      0
    elsif issues.open.count == 0
      100
    else
      issues_progress(false) + issues_progress(true)
    end
  end

  # The latest due date of an *open* issue or version
  def opened_due_date
    @opened_due_date ||= [
      issues.open.maximum('due_date'),
      shared_versions.open.maximum('effective_date'),
      Issue.open.fixed_version(shared_versions.open).maximum('due_date')
    ].compact.max
  end
end
