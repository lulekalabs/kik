class UpdateKasesWithTitle < ActiveRecord::Migration
  def self.up
    add_column :kases, :title, :string
    add_index :kases, :title
  end

  def self.down
    remove_column :kases, :title
  end
end
