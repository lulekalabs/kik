class UpdateSearchFilterWithDigestedTimestamp < ActiveRecord::Migration
  def self.up
    add_column :search_filters, :digested_at, :datetime
    add_index :search_filters, :digested_at
    add_column :search_filters, :finder_type, :string
    add_index :search_filters, :finder_type
  end

  def self.down
    remove_column :search_filters, :digested_at
    remove_column :search_filters, :finder_type
  end
end
