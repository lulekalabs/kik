# 20091102160741_update_kases_with_academic_title.rb
class UpdateKasesWithAcademicTitle < ActiveRecord::Migration
  def self.up
    add_column :kases, :sender_academic_title_id, :integer
  end

  def self.down
    remove_column :kases, :sender_academic_title_id
  end
end
