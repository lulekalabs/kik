class Memorize  < ActiveRecord::Base
  belongs_to :advocate_profile, :class_name => "Person", :foreign_key => "advocate_id"
end