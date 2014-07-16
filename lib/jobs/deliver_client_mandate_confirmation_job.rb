class DeliverClientMandateConfirmationJob < Struct.new(:mandate_id)

  def perform
    if mandate = AdvocateMandate.created.find(mandate_id)
      MandateMailer.dispatch :client_mandate_confirmation, mandate
    end
  rescue ActiveRecord::RecordNotFound => ex
    puts "** Notice: Mandate ID #{mandate_id} not found. It was either deleted or accepted/declined by the client already."
  end

end  
