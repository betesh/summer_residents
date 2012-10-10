module SummerResidents
  class Family < ActiveRecord::Base
    attr_accessible :bungalow_id, :father_id, :home_id, :mother_id
  end
end
