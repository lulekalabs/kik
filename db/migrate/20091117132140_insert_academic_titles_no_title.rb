# 20091117132140_insert_academic_titles_no_title.rb
class InsertAcademicTitlesNoTitle < ActiveRecord::Migration
  def self.up
    add_index :academic_titles, :name, :unique => true
    execute "REPLACE INTO academic_titles(name, created_at, updated_at) " +
      "VALUES('kein Titel', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}');"
  end

  def self.down
    remove_index :academic_titles, :name
  end
end
