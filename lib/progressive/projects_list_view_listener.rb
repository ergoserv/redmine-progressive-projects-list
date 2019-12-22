class Progressive::ProjectsListViewListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_sidebar, partial: 'progressive_sidebar'
  render_on :view_projects_show_left,   partial: 'progressive_overview', locals: { side: :left }
  render_on :view_projects_show_right,  partial: 'progressive_overview', locals: { side: :right }

  def view_layouts_base_html_head(context)
    stylesheet_link_tag('progressive_projects_list', :plugin => :progressive_projects_list)
  end
end
