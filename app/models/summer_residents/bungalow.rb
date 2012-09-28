module SummerResidents
  class Bungalow < ActiveRecord::Base
    has_one :family, :dependent => :nullify
    validates_presence_of :name
    validates :phone, :numericality => true, :length => { :is => 10 }, :allow_nil => true
    attr_accessible :unit
  end
end
