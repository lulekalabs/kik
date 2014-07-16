# stores and sends all press related contacts ("Pressekontakt")
class PressContact < Contact

  #--- validations
  validates_presence_of :sender_gender
  
end