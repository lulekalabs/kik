# Advocate has indicated that she received a mandate by the client, see more in Mandate class
class AdvocateMandate < Mandate
  
  #--- validations
  validates_presence_of :kase_id
  validates_uniqueness_of :advocate_id, :scope => :kase_id
  
  #--- callbacks
  after_create :send_client_mandate_confirmation
  
  protected
  
  def send_client_mandate_confirmation
    if RAILS_ENV == "development"
      MandateMailer.dispatch :client_mandate_confirmation, self
    else
      Delayed::Job.enqueue DeliverClientMandateConfirmationJob.new(self.id), 0, Time.now.utc + 1.minutes
    end
  end
  
  def enter_accepted
    self.accepted_at = Time.now.utc
  end
  
  def after_accepted
    MandateMailer.deliver_notify_mandate_accepted(self)
  end

  def enter_declined
    self.declined_at = Time.now.utc
  end
  
  def after_declined
    MandateMailer.deliver_notify_mandate_declined(self)
  end
  
end