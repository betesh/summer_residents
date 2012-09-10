module SummerResidents
  class Bungalow < ActiveRecord::Base
    attr_accessible :name, :phone, :unit
  end
end
