##
# Factory class that's evaluated inside the permissions
# definition block to register new permissions.

module Canaid
  module Factories
    class Factory
      def can(name, obj_class, priority, &block)
        Canaid::PermissionsHolder.instance.register(
          name, obj_class, priority, &block
        )
      end
    end
  end
end