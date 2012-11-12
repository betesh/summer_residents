module SummerResidents
  class HomesController < FamilyForeignKeysController
private
    def model_attributes
      [:address, :city, :state, :zip, :phone, :apartment, :country]
    end
  end
end
