# Journalis or "Journalisten und Medien" newsletter subscription
class JournalistEnrollment < Enrollment

  #--- validations
  validates_uniqueness_of :email

  #--- instance methods
  
  def to_s
    "Newsletter für Journalisten und Medien"
  end

  # also delete the journalist if she is still around
  def after_destroy
    if self.person && (journalist_to_delete = Person.find_by_id(self.person.id))
      journalist_to_delete.destroy
    end
  end

end