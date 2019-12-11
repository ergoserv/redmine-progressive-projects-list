class Progressive::RecentProjectsViewListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_sidebar, partial: 'progressive_recent_projects'
end
