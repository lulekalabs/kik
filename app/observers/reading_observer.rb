# Sends mail when a readable was read
class ReadingObserver < ActiveRecord::Observer 
  observe :reading
  
  def after_create(reading)
    if reading.readable.is_a?(Response)
      ResponseMailer.dispatch(:read, reading.readable)
    end
  end
  
end 
