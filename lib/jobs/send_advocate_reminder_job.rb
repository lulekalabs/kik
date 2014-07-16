class SendAdvocateReminderJob

  def perform
    Response.visible.kase_open.advocate_reminder.all.each do |response|
      # ResponseMailer.deliver_advocate_reminder response # <- creates a warning which may lead to the case where job is canceled
      ResponseMailer.dispatch :advocate_reminder, response
      response.update_attribute(:advocate_reminded_at, Time.now.utc)
    end
  end

end  
