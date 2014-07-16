# e.g. Zuständige Rechtsanwaltskammer
class BarAssociation < ActiveRecord::Base
  
  # for active scaffold
  def to_label
    "Rechtsanwaltskammer: #{self.name}"
  end

end
