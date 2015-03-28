module Progressive::ApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.class_eval do

      def progressive_setting(key)
        if request.params[:progressive]
          session[:progressive] = true
          session[key] = request.params[key]
        elsif session[:progressive]
          session[key]
        else
          Setting.plugin_progressive_projects_list[key.to_s]
        end
      end

      def progressive_setting?(key)
        progressive_setting(key).present?
      end
    end
  end
end

unless ApplicationHelper.include? Progressive::ApplicationHelperPatch
  ApplicationHelper.send(:include, Progressive::ApplicationHelperPatch)
end
