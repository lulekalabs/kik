module Admin::MessagesHelper

  def type_column(record)
    "#{record.type}".underscore.humanize.titleize
  end

  def sender_id_column(record)
    sender = record.to_sender
    mail_to(sender.email, sender.name_and_email)
  end

  def receiver_id_column(record)
    receiver = record.to_receiver
    mail_to(receiver.email, receiver.name_and_email)
  end
  
  def type_column(record)
    record.class.human_name
  end
  
  def status_column(record)
    record.status ? record.human_current_state_name : '-'
  end
  
end
