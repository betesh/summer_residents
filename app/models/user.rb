require EasyRailsAuthentication::Engine.config.root + 'app' + 'models' + 'user'

class User
  include ResidentOrUser
  has_one :resident, class_name: "SummerResidents::Resident", dependent: :destroy
  [:husband_and_kids, :wife_and_kids, :first_name, :last_name].each { |col|
   delegate col, to: :resident
  }
end

