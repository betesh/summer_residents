module SummerResidents
  class ResidentsController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:edit, :update, :new, :create]
    before_filter :require_administrator_priveleges_if_different_user, only: [:edit, :update]
    before_filter :require_administrator_priveleges_if_user_doesnt_match_family_id, only: [:new, :create]

    def create
      create_resident_and_assign_to_family
      assign_resident_attributes
      @resident.user = User.initialize_without_password(params[:email])
      success = @resident.save
      EasyRailsAuthentication::AuthenticationHelper.SendPasswordInitializationEmailTo @resident.email if success
      show_unless_errors success
    end

    def new
      create_resident_and_assign_to_family
      edit_but_show_if_cancelled
    end

    def edit
      @resident = Resident.find(params[:id])
      set_type
      edit_but_show_if_cancelled
    end
  
    # PUT /residents/1
    # PUT /residents/1.json
    def update
      @resident = Resident.find(params[:id])
      assign_resident_attributes
      @resident.user.email = params[:email].blank? ? nil : params[:email]
      set_type
      show_unless_errors @resident.save
    end
  
    # DELETE /residents/1
    # DELETE /residents/1.json
    def destroy
      Resident.find(params[:id]).destroy
  
      respond_to do |format|
        format.js { render nothing: true }
      end
    end
private
    def create_resident_and_assign_to_family
      @resident = Resident.new
      @resident.user = User.new
      assign_resident_to_family
    end

    def assign_resident_to_family
      set_type
      family = Family.find(params[:fam_id])
      case @type.to_sym
        when :Mother
          @resident.husband_and_kids = family
        when :Father
          @resident.wife_and_kids = family
        else raise "Invalid Resident type.  Should be either :Mother or :Father"
      end
    end

    def set_type
      @type = params[:type]
    end

    def assign_resident_attributes
      [:first_name, :last_name, :cell].each { |f|
        @resident.__send__ "#{f}=", params[f]
      }
    end

    def edit_but_show_if_cancelled
      respond_to do |format|
        format.js { render action: params[:cancel] ? :show : :edit }
      end
    end

    def show_unless_errors if_save
      respond_to do |format|
        format.js { render action: (if_save ? :show : :errors) }
      end
    end
  end
end
