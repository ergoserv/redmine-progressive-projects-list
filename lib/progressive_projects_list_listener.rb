class ProgressiveProjectsListListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    stylesheet_link_tag('progressive_projects_list', :plugin => :progressive_projects_list)
  end
end
