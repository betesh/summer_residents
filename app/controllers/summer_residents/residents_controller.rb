module SummerResidents
  class ResidentsController < SummerResidentsController
    # GET /residents/1/edit
    def edit
      @resident = Resident.find(params[:id])
    end
  
    # PUT /residents/1
    # PUT /residents/1.json
    def update
      mass_assign Resident
  
      respond_to do |format|
        if @resident.save
          format.html { redirect_to @resident, :notice => 'Resident was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @resident.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /residents/1
    # DELETE /residents/1.json
    def destroy
      @resident = Resident.find(params[:id])
      @resident.destroy
  
      respond_to do |format|
        format.html { render nothing: true }
        format.json { head :no_content }
      end
    end
  end
end
