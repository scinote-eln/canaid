module Canaid
  class Configuration
    attr_accessor :permissions_paths

    def initialize
      @permissions_paths = ['app/permissions/**/*.rb']
    end
  end
end