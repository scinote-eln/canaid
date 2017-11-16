##
# Main entry point for registering permissions.

module Canaid
  module Permissions
    def self.register(&block)
      factory = Canaid::Factories::Factory.new
      if block_given?
        factory.instance_eval(&block)
      end
    end

    def self.register_generic(&block)
      factory = Canaid::Factories::FactoryGeneric.new
      if block_given?
        factory.instance_eval(&block)
      end
    end

    def self.register_for(obj_class, &block)
      factory = Canaid::Factories::FactoryForObjClass.new(obj_class)
      if block_given?
        factory.instance_eval(&block)
      end
    end
  end
end