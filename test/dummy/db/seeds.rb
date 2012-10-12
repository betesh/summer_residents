SR = SummerResidents
User.delete_all
SR::Family.delete_all
puts "Creating admin user"
admin = User.initialize_without_password "admin@ou.ch"
admin.password = admin.password_confirmation = "1"
admin.admin = true
admin.save!
puts "Admin user created"
(1..50).each { |i|
  puts "Creating family ##{i}"
  fam = SR::Family.new
  f = SR::Resident.new
  f.user = User.new
  m = SR::Resident.new
  m.user = User.new
  f.user.email = "dad#{i}@somewhere.el.se"
  m.user.email = "mom#{i}@somewhere.el.se"
  f.user.password = f.user.password_confirmation = m.user.password = m.user.password_confirmation = "2"
  f.first_name = "Johnny"
  f.last_name = "Appleseed"
  m.first_name = "Emilia"
  m.last_name = "Bedilia"
  fam.father = f
  fam.mother = m
  fam.save!
  puts "Family ##{i} created"
}
