# Mails to communicate on comments (antworten)
class CommentMailer < Notifier

  # trac #544
  def notify(comment)
    setup_email(comment)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject    = "Neue #{comment.human_name} #{comment.commentable.number} bitte freischalten"
  end
  
  # trac #541
  def approving(comment)
    setup_email(comment)
    @subject    = "Ihr #{comment.human_name} vom #{I18n.l(comment.created_at)}"
  end

  # trac #542
  def approved(comment)
    setup_email(comment)
    @subject    = "#{comment.person.title_and_name}, Ihr Nachtrag zur Frage vom #{I18n.l(comment.created_at)} ist nun freigeschaltet"
  end

  # trac #545/#546
  def posted(comment, receiver)
    setup_email(comment, receiver)
    @from       = self.admin_email
    @subject    = "Neue Nachricht von #{comment.person.title_and_name}"
  end
  
  # trac #543
  def updated_response(comment, response)
    setup_email(comment)
    @recipients        = response.person
    @body[:receiver]   = response.person
    @body[:response]   = response
    @subject    = "#{comment.person.title_and_name}, Nachtrag zu einer von Ihnen beworbenen #{response.class.human_name}"
  end

  # trac #583
  def posted_reviewer(comment, receiver)
    setup_email(comment, receiver)
    @subject    = "#{comment.commentable.reviewer.title_and_name}, Ihre Anwaltsbewertung wurde kommentiert"
  end

  protected
  
  def setup_email(comment, receiver=nil, sender=nil)
    load_settings
    receiver            = receiver || comment.person
    @recipients         = receiver.email
    @from               = self.admin_email
    @subject            = "#{self.site_url} "
    @sent_on            = Time.now
    @body[:receiver]    = receiver
    @body[:comment]     = comment
    @body[:commentable] = comment.commentable
    @body[:kase]        = comment.commentable.is_a?(Response) ? comment.commentable.kase: comment.commentable
    @body[:response]    = comment.commentable.is_a?(Response) ? comment.commentable : nil
  end
    
end
