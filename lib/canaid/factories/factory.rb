##
# Factory class that's evaluated inside the permissions
# definition block to register new permissions.

module Canaid
  module Factories
    class Factory
      def can(name, obj_class, *args, &block)
        raise ArgumentError.new(
          "wrong number of arguments (given #{args.length + 2}, expected 2-3)"
        ) if (args && args.length > 1)
        priority = args ? args[0] : nil
        Canaid::PermissionsHolder.instance.register(
          name, obj_class, priority, &block
        )
      end
    end
  end
end