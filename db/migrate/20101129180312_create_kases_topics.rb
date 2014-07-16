class CreateKasesTopics < ActiveRecord::Migration
  def self.up
    create_table :kases_topics, :id => false do |t|
      t.integer  :kase_id
      t.integer  :topic_id
    end
    add_index :kases_topics, [:kase_id, :topic_id]
  end

  def self.down
    drop_table :kases_topics
  end
end
