module SummerResidents
  class Bungalow < ActiveRecord::Base
    has_one :family, :dependent => :nullify
    validates_presence_of :name
    attr_accessible :phone, :unit
  end
end
