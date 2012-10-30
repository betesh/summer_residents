require File.expand_path('../../user', __FILE__)

module SummerResidents
  class Resident < ActiveRecord::Base
    include ResidentOrUser
    has_one :husband_and_kids, :class_name => 'Family', :dependent => :nullify, :foreign_key => :mother_id
    has_one :wife_and_kids, :class_name => 'Family', :dependent => :nullify, :foreign_key => :father_id
    belongs_to :user
    validates_presence_of :first_name, :last_name
    validates :cell, :numericality => true, :length => { :is => 10 }, :allow_nil => true

    validate :valid_user

    delegate :email, :to => :user
  private
    def valid_user
      u = self.user
      if u
        if u.invalid?
          u.errors.each { |k, e| @errors.add("user-#{k}",e) unless :email == k.to_sym }
          u.errors[:email].each { |e| @errors.add(:email, e) }
        end
      else
        @errors.add(:user, "User must be initialized with an email address and password")
      end
    end
  end
end
