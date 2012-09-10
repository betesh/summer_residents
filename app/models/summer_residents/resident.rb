module SummerResidents
  class Resident < ActiveRecord::Base
    attr_accessible :cell, :first_name, :last_name, :user_id
  end
end
