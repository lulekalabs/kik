class AdminUserMailer < Notifier
  
  def reset_password(user)
    setup_email(user)
    @subject    = "#{user.login}, Ihr Passwort für den Admin-Login!"
  end

  protected
  
  def setup_email(user)
    load_settings
    @recipients    = "#{user.email}"
    @from          = self.admin_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:user]   = user
  end
    
end
