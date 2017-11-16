module Canaid
  class Configuration
    attr_accessor :permissions_path

    def initialize
      @permissions_path = 'app/permissions/**/*.rb'
    end
  end
end