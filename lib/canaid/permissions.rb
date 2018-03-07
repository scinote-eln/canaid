##
# Main entry point for registering permissions.
module Canaid
  module Permissions
    require 'docile'

    def self.register(&block)
      Docile.dsl_eval(Canaid::Factories::Factory.new, &block)
    end

    def self.register_generic(&block)
      Docile.dsl_eval(Canaid::Factories::FactoryGeneric.new, &block)
    end

    def self.register_for(obj_class, &block)
      Docile.dsl_eval(Canaid::Factories::FactoryForObjClass.new(obj_class), &block)
    end
  end
end