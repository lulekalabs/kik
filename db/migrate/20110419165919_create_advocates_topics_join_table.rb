class CreateAdvocatesTopicsJoinTable < ActiveRecord::Migration
  def self.up
    create_table "advocates_topics", :id => false, :force => true do |t|
      t.integer "advocate_id"
      t.integer "topic_id"
    end
    add_index "advocates_topics", ["advocate_id", "topic_id"]
  end

  def self.down
    drop_table :advocates_topics
  end
end
