# 20091102143028_update_people_with_academic_title
class UpdatePeopleWithAcademicTitle < ActiveRecord::Migration
  def self.up
    add_column :people, :academic_title_id, :integer
    remove_column :people, :title
  end

  def self.down
    remove_column :people, :academic_title_id
    add_column :people, :title, :string
  end
end
