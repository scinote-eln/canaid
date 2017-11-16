##
# Gem version file.

module Canaid
  VERSION = File.read(
    "#{File.dirname(__FILE__)}/../../VERSION"
  ).strip.freeze
end
