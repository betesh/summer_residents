EasyRailsAuthentication.configure do |config|
  email = "summer@the_bea.ch"
  config.contact_info = "Summer Residents Team (#{email})"
  config.send_mail_from = email
  config.signature = "Cheers!"
end
