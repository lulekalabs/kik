class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table "visits", :force => true do |t|
      t.integer  "visitor_id"
      t.integer  "visited_id"
      t.string   "visited_type"
      t.datetime "created_at"
      t.string   "uuid"
      t.boolean  "unique",       :default => false, :null => false
    end

    add_index "visits", ["unique"], :name => "index_visits_on_unique"
    add_index "visits", ["uuid"], :name => "index_visits_on_uuid"
    add_index "visits", ["visited_id", "visited_type"], :name => "index_visits_on_visited_id_and_visited_type"
    add_index "visits", ["visitor_id"], :name => "index_visits_on_visitor_id"
  end

  def self.down
    drop_table :visits
  end
end
