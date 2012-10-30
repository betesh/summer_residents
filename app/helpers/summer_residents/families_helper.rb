module SummerResidents
  module FamiliesHelper
    def new_if_nil p
      return p if !p.nil?
      p = Resident.new
      p.user = User.new
      p
    end
  end
end
