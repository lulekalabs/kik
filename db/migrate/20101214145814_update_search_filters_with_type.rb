class UpdateSearchFiltersWithType < ActiveRecord::Migration
  def self.up
    add_column :search_filters, :type, :string
    add_index :search_filters, :type
  end

  def self.down
    remove_column :search_filters, :type
  end
end
