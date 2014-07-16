class RecreatePeopleSpokenLanguages < ActiveRecord::Migration
  def self.up
    drop_table "people_spoken_languages"
    create_table "people_spoken_languages", :id => false do |t|
      t.integer "person_id"
      t.integer "spoken_language_id"
    end
    add_index "people_spoken_languages", ["person_id", "spoken_language_id"], :name => "fk_person_language"
  end

  def self.down
    drop_table "people_spoken_languages"
    create_table "people_spoken_languages" do |t|
      t.integer "person_id"
      t.integer "spoken_language_id"
    end
    add_index "people_spoken_languages", ["person_id", "spoken_language_id"], :name => "fk_person_language"
  end
end
