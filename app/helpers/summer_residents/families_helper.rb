module SummerResidents
  module FamiliesHelper
    def new_if_nil p
      return p if !p.nil?
      p = Resident.new
      p.user = User.new
      p
    end

    def show_or_blank family, fk
      record = family.__send__(fk)
      { partial: "summer_residents/#{fk}s/#{record ? :show : :blank }", locals: { r: record } }
    end
  end
end
