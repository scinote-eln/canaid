##
# This class makes sure that PermissionsHelper is included
# in ActionControllers and ActionViews, as well as that the
# permissions are registered from the correct path.

module Canaid
  class Railtie < Rails::Railtie
    config.after_initialize do
      files = []
      Canaid.configuration.permissions_paths.each do |p|
        files |= Dir[File.expand_path(p)]
      end
      files.each do |f|
        # By requiring those files, Ruby will execute them
        require(f)
      end
    end

    initializer 'canaid.action_view' do
      ActiveSupport.on_load :action_view do
        require 'canaid/helpers/permissions_helper'
        include Canaid::Helpers::PermissionsHelper
      end
    end
    initializer 'canaid.action_controller' do
      ActiveSupport.on_load :action_controller do
        require 'canaid/helpers/permissions_helper'
        include Canaid::Helpers::PermissionsHelper
      end
    end
  end
end