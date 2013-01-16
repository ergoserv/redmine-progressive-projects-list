Redmine::Plugin.register :progressive_projects_list do
  name 'Progressive Projects List plugin'
  author 'Dmitry Babenko'
  description 'Projects List with menus and progress bars.'
  version '0.2.0'
  url 'http://stgeneral.github.com/redmine-progressive-projects-list/'
  author_url 'https://github.com/stgeneral'

  settings :default => {
    'show_project_description' => false,
    'show_project_progress'    => true,
    'show_project_menu'        => false
  }, :partial => 'settings/progressive_projects_list'
end

if Rails::VERSION::MAJOR >= 3
  require 'progressive_projects_list'
  require 'progressive/projects_helper_patch'
  require 'progressive/projects_list_view_listener'
else
  # Rails 2.x (ChiliProject) compatibility
  require 'dispatcher'
  Dispatcher.to_prepare :progressive_projects_list do
    require_dependency 'progressive_projects_list'
    require_dependency 'progressive/projects_helper_patch'
    require_dependency 'progressive/application_helper_patch'
  end
end
