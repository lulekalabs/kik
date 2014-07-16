class ReviewMailer < Notifier

  # ?
  def activate(review)
    setup_email(review)
    @subject    = "#{review.reviewer.title_and_name}, bitte bestätigen Sie Ihre Bewertung auf #{project_name}"
    @body = "Not defined."
  end

  # #576
  def activated(review)
    setup_email(review)
    @subject    = "#{review.reviewer.title_and_name}, Ihre Anwaltsbewertung wird geprüft"
  end

  # #577
  def notify(review)
    setup_email(review)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject       = "Anwaltsbewertung von #{review.reviewer.salutation_and_title_and_last_name} (Nr. #{review.number}) prüfen und freigeben"
  end

  # #578
  def opened_to_reviewer(review)
    setup_email(review)
    @recipients      = review.reviewer.name_and_email
    @subject         = "#{review.reviewer.title_and_name}, Ihre Anwaltsbewertungen ist nun freigeschaltet"
  end

  # #579
  def opened_to_reviewee(review)
    setup_email(review)
    @recipients      = review.reviewee.name_and_email
    @body[:receiver] = review.reviewee
    @subject         = "#{review.reviewee.title_and_name}, eine neue Anwaltsbewertung"
  end

  # ?
  def closed_to_reviewer(review)
    setup_email(review)
    @recipients      = review.reviewer.name_and_email
    @subject         = "#{review.reviewer.title_and_name}, Ihre Bewertung vom #{I18n.l(review.created_at)} wurde geschlossen"
    @body = "Not defined."
  end

  # ?
  def closed_to_reviewee(review)
    setup_email(review)
    @recipients      = review.reviewee.name_and_email
    @body[:receiver] = review.reviewee
    @subject         = "#{review.reviewer.title_and_name}, die Bewertung vom #{I18n.l(review.created_at)} wurde geschlossen"
    @body = "Not defined."
  end

  protected
  
  def setup_email(review)
    load_settings
    @recipients      = review.reviewer.name_and_email
    @from            = self.signup_email
    @subject         = "#{self.site_url} "
    @sent_on         = Time.now
    @body[:receiver] = review.reviewer
    @body[:review]   = review
    @body[:reviewer] = review.reviewer
    @body[:reviewee] = review.reviewee
    @body[:user] = @user = review.reviewer.user
  end
    
end
