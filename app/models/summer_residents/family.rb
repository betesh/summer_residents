module SummerResidents
  class Family < ActiveRecord::Base
    belongs_to :bungalow, :dependent => :destroy
    belongs_to :home, :dependent => :destroy
    belongs_to :mother, :class_name => 'Resident', :foreign_key => 'mother_id'
    belongs_to :father, :class_name => 'Resident', :foreign_key => 'father_id'
  end
end
