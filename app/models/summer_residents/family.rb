module SummerResidents
  class Family < ActiveRecord::Base
    belongs_to :bungalow, :dependent => :destroy
    belongs_to :home, :dependent => :destroy
    belongs_to :mother, :class_name => 'Resident', :foreign_key => 'mother_id'
    belongs_to :father, :class_name => 'Resident', :foreign_key => 'father_id'
    validate :father_cannot_be_a_mother, :if => :father_id
    validate :mother_cannot_be_a_father, :if => :mother_id
    validate :valid_father, :if => :father
    validate :valid_mother, :if => :mother
private
    def father_cannot_be_a_mother
      @errors.add(:father, "#{self.father.full_name} cannot become the mother of any family because it is already the father of a family") if self.class.find_by_father_id(self.mother_id)
    end

    def mother_cannot_be_a_father
      @errors.add(:mother, "#{self.mother.full_name} cannot become the father of any family because it is already the mother of a family") if self.class.find_by_mother_id(self.father_id)
    end

    def valid_parent parent, name
      if parent && parent.invalid?
        parent.errors.each { |k, e| @errors.add("#{name}-#{k}",e) }
      end
    end

    def valid_father
      valid_parent self.father, :father
    end

    def valid_mother
      valid_parent self.mother, :mother
    end
  end
end
