class CancelQuestionsJob

  def perform
    #--- close mandated questions
    Kase.open.with_unanswered_received_mandates_more_than_24_hours_ago.each do |question|
      question.cancel!
    end
    
    #--- close already expired questions
    Kase.open.expired.all.each do |question|
      question.cancel!
    end
  end

end  
