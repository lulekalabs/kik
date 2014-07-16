# 20091015180158_update_people_with_journalists
class UpdatePeopleWithJournalists < ActiveRecord::Migration
  def self.up
    add_column :people, :fax_number, :string
    add_column :people, :media, :string
  end

  def self.down
    remove_column :people, :fax_number
    remove_column :people, :media
  end
end
