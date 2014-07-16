# 20091008130653_update_people_with_expertises
class UpdatePeopleWithExpertises < ActiveRecord::Migration
  def self.up
    add_column :people, :primary_expertise_id, :integer
    add_column :people, :secondary_expertise_id, :integer
    
    add_index :people, :primary_expertise_id
    add_index :people, :secondary_expertise_id
  end

  def self.down
    remove_column :people, :primary_expertise_id
    remove_column :people, :secondary_expertise_id
  end
end
