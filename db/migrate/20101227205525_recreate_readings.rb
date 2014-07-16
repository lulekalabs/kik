class RecreateReadings < ActiveRecord::Migration
  def self.up
    drop_table "readings"
    create_table "readings" do |t|
      t.string   "readable_type"
      t.integer  "readable_id"
      t.integer  "person_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "readings", ["person_id"], :name => "index_readings_on_person_id"
    add_index "readings", ["readable_id", "readable_type"], :name => "index_readings_on_readable_id_and_readable_type"
  end

  def self.down
    drop_table "readings"
    create_table "readings", :id => false, :force => true do |t|
      t.string   "readable_type"
      t.integer  "readable_id"
      t.integer  "person_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "readings", ["person_id"], :name => "index_readings_on_person_id"
    add_index "readings", ["readable_id", "readable_type"], :name => "index_readings_on_readable_id_and_readable_type"
  end
end
