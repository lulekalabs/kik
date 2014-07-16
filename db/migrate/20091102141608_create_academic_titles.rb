# 20091102141608_create_academic_titles
class CreateAcademicTitles < ActiveRecord::Migration
  def self.up
    create_table :academic_titles do |t|
      t.column :name, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :academic_titles
  end
end
