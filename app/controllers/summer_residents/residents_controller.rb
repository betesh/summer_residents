module SummerResidents
  class ResidentsController < FamilyForeignKeysController
    skip_before_filter :require_administrator_priveleges, only: [:edit, :update, :new, :create]
    before_filter :require_administrator_priveleges_if_different_user, only: [:edit, :update]
    before_filter :require_administrator_priveleges_if_user_doesnt_match_family_id, only: [:new, :create]
    before_filter :set_type, only: [:edit, :update, :create, :new]

    def create
      create_and_assign_to_family
      assign_attributes
      @instance.user = User.initialize_without_password(email_param)
      success = @instance.save
      EasyRailsAuthentication::AuthenticationHelper.SendPasswordInitializationEmailTo @instance.email if success
      show_unless_errors success
    end

    # PUT /residents/1
    # PUT /residents/1.json
    def update
      @instance = Resident.find(params[:id])
      assign_attributes
      @instance.user.email = email_param
      show_unless_errors @instance.save
    end

    helper_method :locals
private
    def create_and_assign_to_family
      @instance = Resident.new
      @instance.user = User.new
      assign_to_family
    end

    def assign_to_family
      family = Family.find(params[:fam_id])
      case @type.to_sym
        when :Mother
          @instance.husband_and_kids = family
        when :Father
          @instance.wife_and_kids = family
        else raise "Invalid Resident type.  Should be either :Mother or :Father"
      end
    end

    def set_type
      @type = params[:type]
    end

    def model_attributes
      [:first_name, :last_name, :cell]
    end

    def locals
      { r: @instance, type: @type }
    end

    def email_param
      params[:email].blank? ? nil : params[:email]
    end
  end
end
