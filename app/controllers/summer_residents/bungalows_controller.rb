module SummerResidents
  class BungalowsController < FamilyForeignKeysController
private
    def model_attributes
      [:name, :phone, :unit]
    end
  end
end
