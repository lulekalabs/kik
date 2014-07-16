# Client or "Rechtssuchende" newsletter subscription
class AdvocateEnrollment < Enrollment

  #--- validations
  validates_uniqueness_of :email, :message => I18n.t("activerecord.errors.messages.enrollment_email_taken")
  
  #--- instance methods
  
  def to_s
    "Newsletter für Anwälte"
  end
  
end