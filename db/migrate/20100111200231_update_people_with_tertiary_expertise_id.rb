class UpdatePeopleWithTertiaryExpertiseId < ActiveRecord::Migration
  def self.up
    add_column :people, :tertiary_expertise_id, :integer
    add_index :people, :tertiary_expertise_id
  end

  def self.down
    remove_column :people, :tertiary_expertise_id
  end
end
