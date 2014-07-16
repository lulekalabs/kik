# 20091008132440_drop_expertises_people
class DropExpertisesPeople < ActiveRecord::Migration
  def self.up
    drop_table :expertises_people
  end

  def self.down
    create_table :expertises_people do |t|
      t.integer :person_id
      t.integer :expertise_id
    end
    add_index :expertises_people, :person_id
    add_index :expertises_people, :expertise_id
  end
end
