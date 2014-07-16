class UpdateSearchFiltersWithPersonName < ActiveRecord::Migration
  def self.up
    add_column :search_filters, :person_name, :string
  end

  def self.down
    remove_column :search_filters, :person_name
  end
end
