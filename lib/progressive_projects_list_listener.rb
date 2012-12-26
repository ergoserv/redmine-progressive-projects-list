class ProgressiveProjectsListListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    if Setting.plugin_progressive_projects_list['show_project_menu']
      stylesheet_link_tag('progressive_projects_list', :plugin => :progressive_projects_list)
    end
  end
end
