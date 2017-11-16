require 'canaid/configuration'
require 'canaid/factories/factory_for_obj_class'
require 'canaid/factories/factory_generic'
require 'canaid/factories/factory'
require 'canaid/helpers/permissions_helper'
require 'canaid/permissions_holder'
require 'canaid/permissions'
require 'canaid/railtie' if defined?(Rails)
require 'canaid/version'

module Canaid
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Canaid::Configuration.new
  end

  def self.reset
    @configuration = Canaid::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end