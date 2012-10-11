module SummerResidents
  class SummerResidentsController < ::ApplicationController
  protected
    include EasyRailsAuthentication::AuthenticationHelper
    before_filter :require_authentication
    before_filter :require_administrator_priveleges

    def mass_assign modelClass
      singular = (modelClass.to_s.singularize.gsub /.*::/, "").underscore
      instance_variable = "@#{singular}"
      @model = (params.key? :id) ? modelClass.find(params[:id]) : modelClass.new
      attrs = params[singular]
      attrs.keys.each { |attr| @model.__send__ "#{attr}=", attrs[attr] if !attr.ends_with?("_id") }
      instance_variable_set instance_variable, @model
    end
  end
end
