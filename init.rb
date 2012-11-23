Redmine::Plugin.register :progressive_projects_list do
  name 'Progressive Projects List plugin'
  author 'Dmitry Babenko'
  description 'Projects List showing the progress of each project and their versions.'
  version '0.0.1'
  url 'https://github.com/stgeneral/redmine-progressive-projects-list'
  author_url 'https://github.com/stgeneral'
end

require 'progressive_projects_list'