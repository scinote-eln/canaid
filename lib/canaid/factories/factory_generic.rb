##
# Factory class that's evaluated inside the permissions
# definition block to register new generic permissions. Generic
# permissions are the ones that don't have an access object.

module Canaid
  module Factories
    class FactoryGeneric
      def can(name, priority, &block)
        Canaid::PermissionsHolder.instance.register_generic(
          name, priority, &block
        )
      end
    end
  end
end