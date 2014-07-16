class UpdateKasesWithMandated < ActiveRecord::Migration
  def self.up
    add_column :kases, :mandated_person_id, :integer
    add_column :kases, :mandated, :boolean, :default => false, :null => false

    add_index :kases, :mandated_person_id
    add_index :kases, :mandated
  end

  def self.down
    remove_column :kases, :mandated_person_id
    remove_column :kases, :mandated
  end
end
