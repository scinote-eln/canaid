##
# Factory class that's evaluated inside the permissions
# definition block to register new generic permissions. Generic
# permissions are the ones that don't have an access object.

module Canaid
  module Factories
    class FactoryGeneric
      def can(name, *args, &block)
        raise ArgumentError.new(
          "wrong number of arguments (given #{args.length + 1}, expected 1-2)"
        ) if (args && args.length > 1)
        priority = args ? args[0] : nil
        Canaid::PermissionsHolder.instance.register_generic(
          name, priority, &block
        )
      end
    end
  end
end