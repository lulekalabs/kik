class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer  "rating"
      t.integer  "rater_id"
      t.integer  "rateable_id",   :null => false
      t.string   "rateable_type", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ratings", ["rateable_id", "rating"], :name => "index_ratings_on_rateable_id_and_rating"
    add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"
  end

  def self.down
    drop_table :ratings
  end
end
