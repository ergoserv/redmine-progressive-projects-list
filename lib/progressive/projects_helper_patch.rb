module Progressive::ProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.class_eval do

      def render_project_hierarchy_with_progress_bars(projects)
        render_project_nested_lists(projects) do |project|
          s = link_to_project(project, {},
                              class: "#{project.css_classes} #{User.current.member_of?(project) ? 'my-project' : nil}")
          if !progressive_setting?(:show_only_for_my_projects) || User.current.member_of?(project)
            if progressive_setting?(:show_project_menu)
              s << render_project_menu(project) + '<br />'.html_safe
            end
            if project.description.present? && progressive_setting?(:show_project_description)
              s << content_tag('div', textilizable(project.short_description, project: project), 
                               class: 'wiki description')
            end
            if progressive_setting?(:show_project_progress) && User.current.allowed_to?(:view_issues, project)
              s << render_project_progress_bars(project)
            end
          end
          s
        end
      end

      # Returns project's and its versions' progress bars
      def render_project_progress_bars(project)
        project.extend(Progressive::ProjectDecorator)
        s = ''
        if project.issues.count >= 0
          s << '<div class="progressive-project-issues">' + l(:label_issue_plural) + ': ' +
               link_to(l(:label_x_open_issues_abbr, count: project.issues.open.count),
                       controller: 'issues',
                       action: 'index',
                       project_id: project,
                       set_filter: 1) +
               '<small>(' + l(:label_total) + ": #{project.issues.count})</small> "
          s << due_date_tag(project.opened_due_date) if project.opened_due_date
          s << '</div>'
          s << progress_bar([project.issues_closed_percent, 
                             project.issues_completed_percent], 
                            width: '30em', 
                            legend: format('%0.0f%%', project.issues_closed_percent))
        end

        if project.versions.open.any?
          s << '<div class="progressive-project-version">'
          project.versions.open.reverse_each do |version|
            next if version.completed?
            s << l(:label_version) + ' ' + link_to_version(version) + ': ' +
                 link_to(l(:label_x_open_issues_abbr, count: version.open_issues_count),
                         controller: 'issues',
                         action: 'index',
                         project_id: version.project,
                         status_id: 'o',
                         fixed_version_id: version,
                         set_filter: 1) +
                 '<small> / ' +
                 link_to_if(version.closed_issues_count > 0,
                            l(:label_x_closed_issues_abbr,
                              count: version.closed_issues_count),
                            controller: 'issues',
                            action: 'index',
                            project_id: version.project,
                            status_id: 'c',
                            fixed_version_id: version,
                            set_filter: 1) +
                 '</small>' + '. '
            s << due_date_tag(version.effective_date) if version.effective_date
            s << '<br>' +
                 progress_bar([version.closed_percent, version.completed_percent],
                              width: '30em',
                              legend: format('%0.0f%%', version.completed_percent))
          end
          s << '</div>'
        end
        s.html_safe
      end

      def render_project_menu(project)
        links = []
        menu_items_for(:project_menu, project) do |node|
          links << render_menu_node(node, project)
        end
        links.empty? ? nil : content_tag('ul', links.join("\n").html_safe, class: 'progressive-project-menu')
      end

      def due_date_tag(date)
        content_tag(:time, due_date_distance_in_words(date), 
                    class: (date < Date.today ? 'progressive-overdue' : nil), title: date)
      end

      alias_method :render_project_hierarchy_without_progress_bars, :render_project_hierarchy
      alias_method :render_project_hierarchy, :render_project_hierarchy_with_progress_bars
    end
  end
end

unless ProjectsHelper.include? Progressive::ProjectsHelperPatch
  ProjectsHelper.send(:include, Progressive::ProjectsHelperPatch)
end
