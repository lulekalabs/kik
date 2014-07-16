class ContactMailer < Notifier
  
  def message(contact, copy=false)
    setup_email(contact, copy)
    @subject    += "Kontaktanfrage von #{contact.to_sender.title_and_name}"
  end

  def message_copy(contact)
    setup_email(contact, true)
    @subject    += "Ihre Kontaktanfrage \"#{contact.subject}\""
  end

  protected
  
  def setup_email(contact, copy=false)
    load_settings
    @from            = contact.to_sender.name_and_email.blank? ? self.contact_email : contact.to_sender.name_and_email
    @recipients      = contact.to_receiver.name_and_email
    
    if copy
      @cc            = contact.to_sender.name_and_email.blank? ? self.contact_email : contact.to_sender.name_and_email
    end
    @subject           = ""
    @sent_on           = Time.now
    @body[:sender]     = contact.to_sender
    @body[:receiver]   = contact.to_receiver
    @body[:contact]    = contact
    @body[:message]    = if contact.message.blank?
      default_message(contact.to_sender, contact.to_receiver)
    else
      contact.message
    end
  end
  
  def default_message(sender, receiver)
    <<-STR
Hallo #{receiver.name},
Es gab eine Kontaktanfrage auf:

www.kann-ich-klagen.de

Mit freundlichen Grüßen
#{sender.name}
    STR
  end
    
end
