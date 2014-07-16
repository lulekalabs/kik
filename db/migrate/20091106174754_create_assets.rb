class CreateAssets < ActiveRecord::Migration
  def self.up

    create_table :assets do |t|
      t.integer  "parent_id"
      t.integer  "person_id"
      t.integer  "assetable_id"
      t.string   "assetable_type"
      t.string   "url"
      t.string   "name"

      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.datetime "file_updated_at"

      t.string   "type"
      t.text     "description"

      t.timestamps
    end

    add_index "assets", "parent_id"
    add_index "assets", "person_id"
    add_index "assets", ["assetable_id", "assetable_type"]
    
  end

  def self.down
    drop_table :assets
  end
end
