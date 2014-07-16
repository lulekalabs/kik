class UpdatePeopleUpdateViewsCount < ActiveRecord::Migration
  def self.up
    add_column :people, :views_count, :integer, :default => 0, :default => false
    add_index :people, :views_count
  end

  def self.down
    remove_column :people, :views_count
  end
end
