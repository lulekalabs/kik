# Expertise ("Fachgebiet") class is used as "Fachanwalt Fachgebiet" or "Fachanwalt" expertise
#
#   * "Fachgebiet" (Expertise) is always also a "Rechtsgebiet", but
#   * "Rechtsgebiet" (Topic) is not necessary a "Fachgebiet"
#
class Expertise < Topic
  
  #--- scopes
  named_scope :visible, :conditions => ["topics.expertise_only = ? AND topics.topic_only = ?", true, false]
  
  #--- callbacks
  after_destroy :dependent_nullify
  
  protected
  
  def dependent_nullify
    # must nullify the advocat's dependency
  end
  
end