# Mails to register, activate and confirm an advocate
class AdvocateMailer < Notifier

  cattr_accessor :vcf_path
  @@vcf_path = "#{"#{RAILS_ROOT}/public/"}vcf"

  def signup_registered(person)
    setup_email(person)
    @subject    = "#{person.title_and_name}, bitte bestätigen Sie Ihre kostenlose Anmeldung auf kann-ich-klagen.de"
  end

  def signup_confirmed(person)
    setup_email(person)
    @subject    = "#{person.title_and_name}, vielen Dank für die Bestätigung Ihrer kostenlosen Anmeldung auf kann-ich-klagen.de"
  end

  # #493
  def signup_activated(person)
    setup_email(person)
    @subject    = "#{person.title_and_name}, Ihr persönliches Anwaltsprofil ist jetzt aktiv. Bitte loggen Sie sich ein."
    
    part :content_type => "text/plain", 
      :body => render_message("signup_activated", :user => person.user, :person => person)  
    attachment :content_type => "text/x-vcard", :filename => "#{self.project_name}.vcf",
      :body => File.read("#{vcf_path}/#{self.project_name}.vcf")
  end

  def notify(person)
    setup_email(person)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject    = "#{person.title_and_name} hat die Anmeldung als Anwalt gerade bestätigt."
  end
  
  protected
  
  def setup_email(person)
    load_settings
    @recipients    = "#{person.first_name} #{person.last_name} <#{person.email}>"
    @from          = self.signup_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:user]   = @user = person.user
    @body[:person] = person
  end
    
end
