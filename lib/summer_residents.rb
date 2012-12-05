require "summer_residents/engine"

module SummerResidents
  class Configuration
    attr_accessor :families_per_row
    def initialize
      @families_per_row = 4
    end
  end
  class << self
    def config
      @config ||= Configuration.new
    end
  end

  def self.configure
    yield self.config
  end
end
