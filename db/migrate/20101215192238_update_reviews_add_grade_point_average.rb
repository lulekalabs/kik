class UpdateReviewsAddGradePointAverage < ActiveRecord::Migration
  def self.up
    add_column :reviews, :grade_point_average, :float
    add_index :reviews, :grade_point_average
  end

  def self.down
    remove_column :reviews, :grade_point_average
  end
end
