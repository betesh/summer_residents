module SummerResidents
  module FamiliesHelper
    def belongs_to_or_new obj, col, klass
      obj.__send__(col) || klass.new
    end
  end
end
