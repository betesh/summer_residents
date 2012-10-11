module SummerResidents
  class Resident < ActiveRecord::Base
    has_one :husband_and_kids, :class_name => 'Family', :dependent => :nullify, :foreign_key => :mother_id
    has_one :wife_and_kids, :class_name => 'Family', :dependent => :nullify, :foreign_key => :father_id
    belongs_to :user
    attr_accessible :cell, :first_name, :last_name

    after_save :reset_family
    def family
      @family ||= self.wife_and_kids || self.husband_and_kids
    end
  private
    def reset_family
      @family = nil
    end
  end
end

class User < ActiveRecord::Base
  has_one :resident, :class_name => "SummerResidents::Resident", :dependent => :destroy
end
