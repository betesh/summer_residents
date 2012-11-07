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

    def require_administrator_priveleges_if_different_user
      require_administrator_priveleges unless id_matches_current_user
    end

    def id_matches_current_user
      resident = @current_user.resident
      return false if !resident

      id = params[:id].to_i
      family = @current_user.family
      case controller_name
        when "families"
          family && id == family.id
        when "residents"
          id == resident.id || (family && ((family.father && id == family.father.id) || (family.mother && id == family.mother.id)))
        else false
      end
    end

    def require_administrator_priveleges_if_user_doesnt_match_family_id
      require_administrator_priveleges unless user_matches_family_id
    end

    def user_matches_family_id
      resident = @current_user.resident
      return false if !resident
      fam_id = params[:fam_id].to_i
      family = @current_user.family
      family && family.id == fam_id
    end

    def url_for options=nil
      begin
        super options
      rescue ActionController::RoutingError
        main_app.url_for options
      end
    end
  end
end
