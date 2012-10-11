# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase
  fixtures :all
  [:bungalow, :home, :family, :resident].each { |m|
    alias_method m.to_s.pluralize, "summer_residents_#{m.to_s.pluralize}"
  }
end

module EasyRailsAuthentication
  module AuthenticationHelper
    alias_method :protected_log_in_as, :log_in_as
    def log_in_as user
      protected_log_in_as user
    end
  end
end

class ActionController::TestCase
  setup do
    @routes = SummerResidents::Engine.routes
    @controller.log_in_as users(:joe_user)
  end
end
