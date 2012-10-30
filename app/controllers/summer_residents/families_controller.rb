module SummerResidents
  class FamiliesController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:show, :create, :add_user_info]
    before_filter :require_administrator_priveleges_if_different_user, only: [:show]
    before_filter :require_administrator_priveleges_if_not_added_user_info, only: [:create]

    # GET /families
    # GET /families.json
    def index
      @index_action = true
      @families = Family.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @families }
      end
    end
  
    # GET /families/1
    # GET /families/1.json
    def show
      @family = Family.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @family }
      end
    end
  
    def new
      @family = Family.new
    end
  
    def add_user_info
      father = Resident.new
      father.user = @current_user
      @family = Family.new
      @family.father = father

      respond_to do |format|
        format.html  { render action: :new }
        format.json { render json: @family }
      end
    end

    # POST /families
    # POST /families.json
    def create
      @family = Family.new
      [:father, :mother].each do |p|
        parent = Resident.new
        pp = params[p]
        user_exists = added_parent_info? pp
        parent.user = user_exists ? @current_user : User.initialize_without_password(pp[:email])
        parent = @current_user.resident if user_exists && @current_user.resident
        @family.__send__ "#{p}=", parent

        [:first_name, :last_name].each { |col|
          parent.__send__ "#{col}=", pp[col]
        }
      end

      respond_to do |format|
        if @family.save
          uninitialized_pw = User.initialize_without_password("").password_digest
          [@family.father, @family.mother].each { |p|
            user_is_new = p.user.password_digest == uninitialized_pw
            EasyRailsAuthentication::AuthenticationHelper.SendPasswordInitializationEmailTo p.email if user_is_new
          }
          format.html { redirect_to (added_user_info? ? family_url(@family.id) : families_url), notice: 'Family was successfully created.' }
          format.json { render json: @family, status: :created, location: @family }
        else
          format.html { render action: "new" }
          format.json { render json: @family.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /families/1
    # DELETE /families/1.json
    def destroy
      Family.find(params[:id]).destroy
  
      respond_to do |format|
        format.js { render nothing: true }
      end
    end

   helper_method :current_or_new
   helper_method :adding_user_info?
private
    def current_or_new col
      @family.__send__(col) || Resident.new
    end

    def adding_user_info?
      "add_user_info" == params[:action]
    end

    def added_parent_info? p
      params[:adding_user_info] && (@current_user.email == p[:email])
    end

    def added_user_info?
      added_parent_info?(params[:father]) || added_parent_info?(params[:mother])
    end

    def require_administrator_priveleges_if_not_added_user_info
      require_administrator_priveleges unless added_user_info?
    end
  end
end
