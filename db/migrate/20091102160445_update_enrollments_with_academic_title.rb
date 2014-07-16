# 20091102160445_update_enrollments_with_academic_title
class UpdateEnrollmentsWithAcademicTitle < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :academic_title_id, :integer
  end

  def self.down
    remove_column :enrollments, :academic_title_id
  end
end
