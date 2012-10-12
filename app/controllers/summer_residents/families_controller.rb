module SummerResidents
  class FamiliesController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:show]
    before_filter :require_administrator_priveleges_if_different_user, only: [:show]

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
  
    # POST /families
    # POST /families.json
    def create
      @family = Family.new
      [:father, :mother].each do |p|
        parent = Resident.new
        @family.__send__ "#{p}=", parent

        pp = params[p]
        parent.user = User.initialize_without_password pp[:email]
        [:first_name, :last_name].each { |col|
          parent.__send__ "#{col}=", pp[col]
        }
      end

      respond_to do |format|
        if @family.save
          format.html { redirect_to families_url, notice: 'Family was successfully created.' }
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
  end
end
