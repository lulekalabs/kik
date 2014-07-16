class CreateSearchFilters < ActiveRecord::Migration
  def self.up
    create_table :search_filters do |t|
      t.integer "person_id"
      t.string "tags"
      t.integer "topic_id"
      t.integer "postal_code"
      t.integer "radius"
      t.string "province_code"
      t.float "lat"
      t.float "lng"
      t.string "digest", :limit => 1
      t.timestamps
    end
    add_index :search_filters, :person_id
    add_index :search_filters, [:lat, :lng]
  end

  def self.down
    drop_table :search_filters
  end
end
