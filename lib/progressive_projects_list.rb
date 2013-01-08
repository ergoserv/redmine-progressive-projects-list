module ProgressiveProjectsList
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :render_project_hierarchy, :progress_bars
    end
  end

  module InstanceMethods
    def render_project_hierarchy_with_progress_bars(projects)
      render_project_nested_lists(projects) do |project|
        s = link_to_project(project, {}, :class => "#{project.css_classes} #{User.current.member_of?(project) ? 'my-project' : nil}")
        if Setting.plugin_progressive_projects_list['show_project_menu']
          s << render_project_menu(project) + '<br />'.html_safe
        end
        if project.description.present? && Setting.plugin_progressive_projects_list['show_project_description']
            s << content_tag('div', textilizable(project.short_description, :project => project), :class => 'wiki description')
        end
        if Setting.plugin_progressive_projects_list['show_project_progress']
          s << render_project_progress_bars(project)
        end
        s
      end
    end

    # Returns project's and its versions' progress bars
    def render_project_progress_bars(project)
      s = ''
      if project.issues.open.count > 0
        issues_closed_pourcent = (1 - project.issues.open.count.to_f/project.issues.count) * 100
        s << "<div>" + l(:label_issue_plural) + ": " +
          link_to_if(project.issues.open.count > 0, l(:label_x_open_issues_abbr, :count => project.issues.open.count), :controller => 'issues', :action => 'index', :project_id => project, :set_filter => 1) +
          " <small>(" + l(:label_total) + ": #{project.issues.count})</small></div>" +
          progress_bar(issues_closed_pourcent, :width => '30em', :legend => '%0.0f%' % issues_closed_pourcent)
      end

      unless project.versions.open.empty?
        s << "<div>"
        project.versions.open.reverse_each do |version|
          unless version.completed?
            s << l(:label_version) + " " + link_to_version(version) + ": " +
              link_to_if(version.open_issues_count > 0, l(:label_x_open_issues_abbr, :count => version.open_issues_count), :controller => 'issues', :action => 'index', :project_id => version.project, :status_id => 'o', :fixed_version_id => version, :set_filter => 1) +
              "<small> / " + link_to_if(version.closed_issues_count > 0, l(:label_x_closed_issues_abbr, :count => version.closed_issues_count), :controller => 'issues', :action => 'index', :project_id => version.project, :status_id => 'c', :fixed_version_id => version, :set_filter => 1) + "</small>" + ". "
            s << due_date_distance_in_words(version.effective_date) if version.effective_date
            s << "<br>" +
              progress_bar([version.closed_pourcent, version.completed_pourcent], :width => '30em', :legend => ('%0.0f%' % version.completed_pourcent))
          end
        end
        s << "</div>"
      end
      s.html_safe
    end

    def render_project_menu(project)
      links = []
      menu_items_for(:project_menu, project) do |node|
        links << render_menu_node(node, project)
      end
      links.empty? ? nil : content_tag('ul', links.join("\n").html_safe, :class => 'progressive-project-menu')
    end
  end
end

unless ProjectsHelper.included_modules.include? ProgressiveProjectsList
  ProjectsHelper.send(:include, ProgressiveProjectsList)
end
