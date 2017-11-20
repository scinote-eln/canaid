##
# Factory class that's evaluated inside the permissions
# definition block to register new permissions (for object class).

module Canaid
  module Factories
    class FactoryForObjClass
      def initialize(obj_class)
        @obj_class = obj_class
      end

      def can(name, *args, &block)
        raise ArgumentError.new(
          "wrong number of arguments (given #{args.length + 1}, expected 1-2)"
        ) if (args && args.length > 1)
        priority = args ? args[0] : nil
        Canaid::PermissionsHolder.instance.register(
          name, @obj_class, priority, &block
        )
      end
    end
  end
end