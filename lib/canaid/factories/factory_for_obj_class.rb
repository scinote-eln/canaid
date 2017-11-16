##
# Factory class that's evaluated inside the permissions
# definition block to register new permissions (for object class).

module Canaid
  module Factories
    class FactoryForObjClass
      def initialize(obj_class)
        @obj_class = obj_class
      end

      def can(name, priority, &block)
        Canaid::PermissionsHolder.instance.register(
          name, @obj_class, priority, &block
        )
      end
    end
  end
end