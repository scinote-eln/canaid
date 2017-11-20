##
# Singleton class that holds all permission definitions
# so they can be evaluated at run-time.

require 'singleton'
require 'active_support/hash_with_indifferent_access'

module Canaid
  class PermissionsHolder
    include Singleton

    DEFAULT_PRIORITY = 10

    def initialize
      @cans = HashWithIndifferentAccess.new
      @can_obj_classes = HashWithIndifferentAccess.new
    end

    def register(name, obj_class, priority, &block)
      check_if_obj_class_match(name, obj_class)
      _priority = priority == nil ? DEFAULT_PRIORITY : priority
      add_permission(name, obj_class, _priority, &block)
    end

    def register_generic(name, priority, &block)
      check_if_obj_class_match(name, :generic)
      _priority = priority == nil ? DEFAULT_PRIORITY : priority
      add_permission(name, :generic, _priority, &block)
    end

    def has_permission?(name)
      @cans.key?(name)
    end

    def is_generic?(name)
      @can_obj_classes.key?(name) &&
      @can_obj_classes[name] == :generic
    end

    def eval(name, user, obj)
      check_if_exists(name)

      # Check if correct object class was specified
      raise ArgumentError.new(
        "Object of incorrect class specified when calling permission #{name}!"
      ) if obj.class != @can_obj_classes[name]

      result = true
      @cans[name].each do |perm|
        result &&= perm[:block].call(user, obj)
      end

      return result
    end

    def eval_generic(name, user)
      check_if_exists(name)

      # Check if correct object class was specified
      raise ArgumentError.new(
        "Non-generic permission #{name} called with generic arguments!"
      ) if @can_obj_classes[name] != :generic

      result = true
      @cans[name].each do |perm|
        result &&= perm[:block].call(user)
      end

      return result
    end

    private

    def check_if_obj_class_match(name, obj_class)
      if @can_obj_classes.key?(name) &&
         @can_obj_classes[name] != obj_class
        raise ArgumentError.new(
          "Different object classes for same permission #{name} registered!"
        )
     end
    end

    def check_if_exists(name)
      raise ArgumentError.new(
        "Permission #{name} isn't registered!"
      ) unless @cans.key?(name)
    end

    def add_permission(name, obj_class, priority, &block)
      @can_obj_classes[name] = obj_class
      @cans[name] = [] unless @cans.key?(name)
      idx = @cans[name].index {|p| p[:priority] > priority} || -1
      @cans[name].insert(idx, { priority: priority, block: block })
    end
  end
end
