class General < ActionMailer::Base
  default :from => Settings.from_address
  layout 'base_mail'

  def mass_email(text, role)
    to_addresses = Array.new
    if role == "all"
      User.all.each { |u| to_addresses << u.email }
    else
      User.find(:all, :conditions => ["roles = ?", role]).each { |u| to_addresses << u.email }
    end
    @text = text
    mail(:to => to_addresses, :subject => "Mjölk: important information")
  end

  def welcome_beta(user_id)
    user = User.find(user_id)
    mail(:to => to_addresses, :subject => "Welcome @ Mjölk beta user !")
  end

  def welcome_too_many(user_id)
    user = User.find(user_id)
    mail(:to => to_addresses, :subject => "Welcome @ Mjölk ! The app is in beta mode, your account is locked.")
  end
end
