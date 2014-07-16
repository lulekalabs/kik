class CreateSpokenLanguages < ActiveRecord::Migration
  def self.up
    create_table :spoken_languages do |t|
      t.string :name
      t.string :code, :limit => 3, :null => :false
      t.boolean :priority, :null => false, :default => false
      t.timestamps
    end
    add_index :spoken_languages, :name
    add_index :spoken_languages, :code
  end

  def self.down
    drop_table :spoken_languages
  end
end
