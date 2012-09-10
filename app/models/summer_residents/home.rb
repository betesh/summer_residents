module SummerResidents
  class Home < ActiveRecord::Base
    attr_accessible :address, :apartment, :city, :country, :phone, :state, :zip
  end
end
