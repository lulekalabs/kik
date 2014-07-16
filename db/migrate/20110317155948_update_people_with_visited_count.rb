class UpdatePeopleWithVisitedCount < ActiveRecord::Migration
  def self.up
    add_column :people, :visits_count, :integer, :default => 0, :null => false
    add_index :people, :visits_count
  end

  def self.down
    remove_column :people, :visits_count
  end
end
