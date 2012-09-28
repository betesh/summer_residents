module SummerResidents
  class Home < ActiveRecord::Base
    has_one :family, :dependent => :nullify
    validates_presence_of :address, :city, :state
    validates :zip, :numericality => true, :length => { :is => 5 }, :allow_nil => true
    validates :phone, :numericality => true, :length => { :is => 10 }, :allow_nil => true
    attr_accessible :apartment, :country
  end
end
