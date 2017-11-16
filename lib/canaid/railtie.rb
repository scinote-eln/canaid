##
# This class makes sure that PermissionsHelper is included
# in ActionControllers and ActionViews.

module Canaid
  class Railtie < Rails::Railtie
    config.after_initialize do
      Dir[File.expand_path 'app/permissions/**/*.rb'].each do |f|
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