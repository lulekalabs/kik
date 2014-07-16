class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :v
      t.integer :v1
      t.integer :v2
      t.integer :v3
      t.integer :v4
      t.integer :v5

      t.integer :z
      t.integer :z1
      t.integer :z2
      t.integer :z3
      t.integer :z4
      t.integer :z5

      t.integer :m
      t.integer :m1
      t.integer :m2
      t.integer :m3
      t.integer :m4
      t.integer :m5

      t.integer :e
      t.integer :e1
      t.integer :e2
      t.integer :e3
      t.integer :e4
      t.integer :e5

      t.integer :a
      t.integer :a1
      t.integer :a2
      t.integer :a3
      t.integer :a4
      t.integer :a5

      t.float :grade

      t.string :like_description
      t.string :dislike_description
      
      t.string :search_reason
      t.boolean :friend_recommend
      t.boolean :remedy_insured
      t.date :last_advocate_contact
      t.string :advocate_contact_count
      t.string :laswsuit_won
      t.boolean :allow_questions
      
      t.string :type
      t.string :status

      t.integer :reviewer_id
      t.integer :reviewee_id
      
      t.timestamps
    end
    add_index :reviews, :reviewer_id
    add_index :reviews, :reviewee_id
    add_index :reviews, :type
    add_index :reviews, :status
  end

  def self.down
    drop_table :reviews
  end
end
