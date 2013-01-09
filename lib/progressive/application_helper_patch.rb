module Progressive::ApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    # Renders a tree of projects as a nested set of unordered lists
    # The given collection may be a subset of the whole project tree
    # (eg. some intermediate nodes are private and can not be seen)
    def render_project_nested_lists(projects)
      s = ''
      if projects.any?
        ancestors = []
        original_project = @project
        projects.sort_by(&:lft).each do |project|
          # set the project environment to please macros.
          @project = project
          if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
            s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
          else
            ancestors.pop
            s << "</li>"
            while (ancestors.any? && !project.is_descendant_of?(ancestors.last))
              ancestors.pop
              s << "</ul></li>\n"
            end
          end
          classes = (ancestors.empty? ? 'root' : 'child')
          s << "<li class='#{classes}'><div class='#{classes}'>"
          s << h(block_given? ? yield(project) : project.name)
          s << "</div>\n"
          ancestors << project
        end
        s << ("</li></ul>\n" * ancestors.size)
        @project = original_project
      end
      s.html_safe
    end
  end
end

unless ApplicationHelper.included_modules.include? Progressive::ApplicationHelperPatch
  ApplicationHelper.send(:include, Progressive::ApplicationHelperPatch)
end
