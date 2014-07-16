# 20091002200952
class ExpertisesPeopleJoinTable < ActiveRecord::Migration
  def self.up
    create_table :expertises_people do |t|
      t.integer :person_id
      t.integer :expertise_id
    end
    add_index :expertises_people, :person_id
    add_index :expertises_people, :expertise_id
  end

  def self.down
    drop_table :expertises_people
  end
end
