class UpdatePeopleOverdrawnContacts < ActiveRecord::Migration
  def self.up
    add_column :people, :overdrawn_contacts_count, :integer, :default => 0, :null => false
    add_index :people, :overdrawn_contacts_count
  end

  def self.down
    remove_column :people, :overdrawn_contacts_count
  end
end
