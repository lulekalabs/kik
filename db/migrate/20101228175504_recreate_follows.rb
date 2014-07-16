class RecreateFollows < ActiveRecord::Migration
  def self.up
    drop_table "follows"
    create_table "follows" do |t|
      t.integer  "followable_id",                      :null => false
      t.string   "followable_type"
      t.integer  "follower_id",                        :null => false
      t.string   "follower_type"
      t.boolean  "blocked",         :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "follows", ["followable_id", "followable_type"], :name => "index_follows_on_followable_id_and_followable_type"
    add_index "follows", ["follower_id", "follower_type"], :name => "index_follows_on_follower_id_and_follower_type"
  end

  def self.down
    drop_table "follows"
    create_table "follows", :id => false, :force => true do |t|
      t.integer  "followable_id",                      :null => false
      t.string   "followable_type"
      t.integer  "follower_id",                        :null => false
      t.string   "follower_type"
      t.boolean  "blocked",         :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "follows", ["followable_id", "followable_type"], :name => "index_follows_on_followable_id_and_followable_type"
    add_index "follows", ["follower_id", "follower_type"], :name => "index_follows_on_follower_id_and_follower_type"
  end
end
