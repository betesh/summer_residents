module SummerResidents
  class ApplicationController < ActionController::Base
  protected
    include EasyRailsAuthentication::AuthenticationHelper
    before_filter :require_authentication
    before_filter :require_administrator_priveleges
  end
end
