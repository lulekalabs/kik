class UpdatePeopleAddGradePointAverage < ActiveRecord::Migration
  def self.up
    add_column :people, :grade_point_average, :float
    add_index :people, :grade_point_average
  end

  def self.down
    remove_column :people, :grade_point_average
  end
end
