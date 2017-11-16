##
# Module that is injected into ActionControllers and ActionViews
# to provide access to permission helper methods.

module Canaid
  module Helpers
    module PermissionsHelper
      def method_missing(method, *args, &block)
        # Check if called method name matches format can_<perm>?
        res = method.to_s.match(/^can_(.+)\?$/)
        if res != nil && res.length > 1
          name = res[1]

          # Validate arguments
          if args.length > 2
            raise ArgumentError.new(
              "Method #{method.to_s} should have 0, 1 or 2 arguments."
            )
          end

          holder = Canaid::PermissionsHolder.instance

          # Validate if permission exists
          raise ArgumentError.new(
            "Method #{method.to_s} has no related permission registered."
          ) unless holder.has_permission?(name)

          # Parse arguments differently whether the permission
          # is generic or not
          if holder.is_generic?(name)
            user = args.length == 0 ? current_user : args[0]
            return holder.eval_generic(name, user)
          else
            user = args.length == 1 ? current_user : args[0]
            obj = args.length == 1 ? args[0] : args[1]
            return holder.eval(name, user, obj)
          end
        else
          super
        end
      end

      def respond_to_missing?(method, *args)
        method.to_s.match(/^can_(.+)\?$/) || super
      end
    end
  end
end
