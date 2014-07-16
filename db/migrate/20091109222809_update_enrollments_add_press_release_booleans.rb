# 20091109222809_update_enrollments_add_press_release_booleans.rb
class UpdateEnrollmentsAddPressReleaseBooleans < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :press_release_per_email, :boolean, :default => false
    add_column :enrollments, :press_release_per_fax, :boolean, :default => false
    add_column :enrollments, :press_release_per_mail, :boolean, :default => false
  end

  def self.down
    remove_column :enrollments, :press_release_per_email
    remove_column :enrollments, :press_release_per_fax
    remove_column :enrollments, :press_release_per_mail
  end
end
