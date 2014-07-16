class UpdateSearchFilters < ActiveRecord::Migration
  def self.up
    remove_column :search_filters, :topic_id
    add_column :search_filters, :city, :string
    add_index :search_filters, :city
  end

  def self.down
    add_column :search_filters, :topic_id, :integer
    remove_column :search_filters, :city
  end
end
