module SummerResidents
  class BungalowsController < FamilyForeignKeysController
    # GET /bungalows/1/edit
    def edit
      @instance = model_name.find(params[:id])
      edit_but_show_if_cancelled
    end
  
    # POST /bungalows
    # POST /bungalows.json
    def create
      create_and_assign_to_family
      assign_attributes
      show_unless_errors @instance.save
    end
  
    # PUT /bungalows/1
    # PUT /bungalows/1.json
    def update
      @instance = model_name.find(params[:id])
      assign_attributes
      show_unless_errors @instance.save
    end
private
    def create_and_assign_to_family
      @instance = model_name.new
      @instance.family = Family.find(params[:fam_id])
    end

    def model_attributes
      [:name, :phone, :unit]
    end
  end
end
