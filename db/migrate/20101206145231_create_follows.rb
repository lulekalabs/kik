class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows, :id => false do |t|
      t.integer  "followable_id",                      :null => false
      t.string   "followable_type"
      t.integer  "follower_id",                        :null => false
      t.string   "follower_type"
      t.boolean  "blocked",         :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index :follows, [:followable_id, :followable_type]
    add_index :follows, [:follower_id, :follower_type]
  end

  def self.down
    drop_table :follows
  end
end
