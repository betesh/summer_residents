module SummerResidents
  class ResidentsController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:edit, :update]
    before_filter :require_administrator_priveleges_if_different_user, only: [:edit, :update]

    # GET /residents/1/edit
    def edit
      @resident = Resident.find(params[:id])
      @type = params[:type]
      respond_to do |format|
        format.js { render action: params[:cancel] ? :show : :edit }
      end
    end
  
    # PUT /residents/1
    # PUT /residents/1.json
    def update
      @resident = Resident.find(params[:id])
      [:first_name, :last_name, :cell].each { |f|
        @resident.__send__ "#{f}=", params[f]
      }
      @resident.user.email = params[:email]
      @type = params[:type]

      respond_to do |format|
        format.js { render action: (@resident.save ? :show : :errors) }
      end
    end
  
    # DELETE /residents/1
    # DELETE /residents/1.json
    def destroy
      Resident.find(params[:id]).destroy
  
      respond_to do |format|
        format.js { render nothing: true }
      end
    end
  end
end
