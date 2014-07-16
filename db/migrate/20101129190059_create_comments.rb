class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text     "message"
      t.integer  "commentable_id"
      t.string   "commentable_type"
      t.integer  "person_id"
      t.timestamps
    end
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, :person_id
  end

  def self.down
    drop_table :comments
  end
end
