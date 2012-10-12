module SummerResidents
  class ResidentsController < SummerResidentsController
    # GET /residents/1/edit
    def edit
      @resident = Resident.find(params[:id])
      respond_to do |format|
        format.js { render action: :edit }
      end
    end
  
    # PUT /residents/1
    # PUT /residents/1.json
    def update
      mass_assign Resident
  
      respond_to do |format|
        format.js { render (@resident.save ? { action: :show } : { nothing: true}) }
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
