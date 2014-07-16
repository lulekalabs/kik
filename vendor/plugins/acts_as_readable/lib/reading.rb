# Note: modified to support People reading instead of User's
# Juergen Fesslmeier
class Reading < ActiveRecord::Base
  belongs_to :person
  belongs_to :readable, :polymorphic => true
  
  validates_presence_of :person_id, :readable_id, :readable_type
  validates_uniqueness_of :person_id, :scope => [:readable_id, :readable_type]
end