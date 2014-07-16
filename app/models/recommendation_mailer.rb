class RecommendationMailer < Notifier
  
  def message(recommendation)
    setup_email(recommendation, recommendation.copy_sender?)
    @subject    += "#{recommendation.to_receiver.title_and_name}, Sie haben eine Empfehlung von #{recommendation.to_sender.title_and_name} erhalten"
  end

  def message_copy(recommendation)
    setup_email(recommendation, true)
    @subject    += "Sie haben #{recommendation.to_sender.title_and_name} eine Empfehlung gesandt"
  end

  protected
  
  def setup_email(recommendation, copy=false)
    load_settings
    if copy
      @cc              = recommendation.to_sender.name_and_email
    end
    @recipients        = recommendation.to_receiver.name_and_email
    @from              = recommendation.to_sender.name_and_email
    @subject           = "#{self.site_url} "
    @sent_on           = Time.now
    @body[:sender]     = recommendation.to_sender
    @body[:receiver]   = recommendation.to_receiver
    @body[:message]    = default_message(recommendation)
  end
  
  def default_message(recommendation)
    sender = recommendation.to_sender
    receiver = recommendation.to_receiver
    message = recommendation.message
    ip = recommendation.ip
    
    inline_message = recommendation.message.blank? ? nil : <<-STR
Ferner möchte ich Ihnen/Dir mitteilen:

#{message}
    STR
    
    <<-STR
Guten Tag #{receiver.title_and_name}!

Ich nutze gerade die Weiterempfehlungsfunktion von www.kann-ich-klagen.de mit der ich Kolleginnen und Kollegen, die ich persönlich kenne, in meinem Namen eine Nachricht als freundschaftlichen Hinweis schicken kann.

Folgende Seite könnte für Sie/Dich interessant sein:

www.kann-ich-klagen.de/anwalt

Man kann sich dort unverbindlich anmelden und erhält ein kostenloses Startguthaben. Die Anmeldung dauert nur wenige Minuten.

Zusätzlich zu einem Startguthaben schenkt man uns beiden als Empfehlender und Empfehlungsempfänger für den Fall einer erfolgreichen, aktivierten Anmeldung ein extra Guthaben. Weitere Informationen und Erklärungen sind auf der oben genannten Seite zu finden.

#{inline_message}

Mit besten Grüßen

#{sender.title_and_name}

IP-Adresse des Empfehlenden: #{ip}
    STR
  end
    
end
