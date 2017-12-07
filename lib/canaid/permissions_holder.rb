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
      unregister_all
    end

    def register(name, obj_class, priority, &block)
      validate_name(name)
      validate_obj_class(obj_class)
      validate_priority(priority)
      validate_block(&block)
      check_if_obj_class_match(name, obj_class)

      _priority = priority == nil ? DEFAULT_PRIORITY : priority
      add_permission(name, obj_class, _priority, &block)
    end

    def register_generic(name, priority, &block)
      validate_name(name)
      validate_priority(priority)
      validate_block(&block)
      check_if_obj_class_match(name, :generic)

      _priority = priority == nil ? DEFAULT_PRIORITY : priority
      add_permission(name, :generic, _priority, &block)
    end

    def has_permission?(name)
      validate_name(name)

      @cans.key?(name)
    end

    def is_generic?(name)
      validate_name(name)
      check_if_exists(name)

      @can_obj_classes.key?(name) &&
      @can_obj_classes[name] == :generic
    end

    def eval(name, user, obj, scope = nil)
      validate_name(name)
      check_if_exists(name)

      # Check if correct object class was specified
      raise ArgumentError.new(
        "Object of incorrect class specified when calling permission #{name}!"
      ) if obj.class != @can_obj_classes[name]

      result = true
      @cans[name].each do |perm|
        if scope
          result &&= scope.instance_exec(user, obj, &perm[:block])
        else
          result &&= perm[:block].call(user, obj)
        end
      end

      return result
    end

    def eval_generic(name, user, scope = nil)
      validate_name(name)
      check_if_exists(name)

      # Check if correct object class was specified
      raise ArgumentError.new(
        "Non-generic permission #{name} called with generic arguments!"
      ) if @can_obj_classes[name] != :generic

      result = true
      @cans[name].each do |perm|
        if scope
          result &&= scope.instance_exec(user, &perm[:block])
        else
          result &&= perm[:block].call(user)
        end
      end

      return result
    end

    def unregister_all
      @cans = HashWithIndifferentAccess.new
      @can_obj_classes = HashWithIndifferentAccess.new
    end

    def print(markdown = false)
      obj_classes = @can_obj_classes.values.select { |oc| oc != :generic }
      # Start with generic
      obj_classes.unshift(:generic)

      obj_classes.uniq.each do |obj_class|
        if obj_class == :generic
          puts '## Generic permissions'
        else
          puts "## #{obj_class} permissions"
        end
        puts ''

        permission_names =
          @can_obj_classes.map { |k, v| v == obj_class ? k : nil }.compact
        permission_names.sort!
        permission_names.each do |pn|
          next if @cans[pn].empty?

          # Extract parameters from first block
          puts '```' if markdown
          md = /.*\|(.*)\|.*/.match(@cans[pn][0][:block].source.split("\n")[0])
          params = md && md.length > 1 ? md[1] : ''
          puts "can_#{pn}?(#{params})"

          # Print individual permissions
          perms = @cans[pn].sort { |e1, e2| e1[:priority] <=> e2[:priority] }
          perms.each_with_index do |perm, idx|
            src = perm[:block].source
            md = /\A\s*can.*(do|\{)\s*(\|.*\|)?(.*)(end|\})\s*\z/m.match(src)
            next unless md.length == 5
            res = md[3]
                  .strip
                  .split("\n")
                  .map(&:strip)
                  .map { |v| "  #{v}" }
                  .join("\n")
            res = "#{res} &&" if perms.length > 1 && idx < perms.length - 1
            puts res
          end
          puts '```' if markdown
          puts ''
        end
      end
    end

    private

    def validate_name(name)
      raise ArgumentError.new(
        'Name must be a Symbol or a String!'
      ) unless [Symbol, String].include?(name.class)
    end

    def validate_obj_class(obj_class)
      raise ArgumentError.new('Nil object class!') if obj_class == nil
    end

    def validate_priority(priority)
      return if priority == nil
      raise ArgumentError.new(
        'Priority must be an Integer!'
      ) unless priority.is_a?(Integer)
    end

    def validate_block(&block)
      raise ArgumentError.new(
        'No block provided for the permission!'
      ) if block == nil
    end

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
