module SummerResidents
  class Home < ActiveRecord::Base
    has_one :family, :dependent => :nullify
    validates_presence_of :address, :city, :state
    attr_accessible :apartment, :country, :phone, :zip
  end
end
