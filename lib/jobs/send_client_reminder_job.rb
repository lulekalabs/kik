class SendClientReminderJob

  def perform
    Kase.open.client_reminder.all.each do |kase|
      KaseMailer.deliver_client_reminder(kase)
      kase.update_attribute(:client_reminded_at, Time.now.utc)
    end
  end

end  
