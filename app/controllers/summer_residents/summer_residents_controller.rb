module SummerResidents
  class SummerResidentsController < ::ApplicationController
  protected
    include EasyRailsAuthentication::AuthenticationHelper
    before_filter :require_authentication
    before_filter :require_administrator_priveleges
  end
end
