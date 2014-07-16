# Client mandates an advocate, see more in Mandate class
class ClientMandate < Mandate
  
  #--- validations
  validates_uniqueness_of :advocate_id, :scope => :kase_id, :if => :advocate?
  
  protected
  
  def advocate?
    !!self.advocate
  end
  
end