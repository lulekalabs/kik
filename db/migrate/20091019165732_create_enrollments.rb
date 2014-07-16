# 20091019165732_create_enrollments.rb
class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.column :person_id, :integer
      
      t.string :gender, :limit => 1
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      
      t.column :type, :string
      t.column :state, :string, :default => 'passive'
      t.column :activation_code, :string
      t.column :activated_at, :datetime
      t.column :deleted_at, :datetime
      t.timestamps
    end
    add_index :enrollments, :person_id
    add_index :enrollments, :type
    add_index :enrollments, :state
    add_index :enrollments, :activation_code
    add_index :enrollments, :email
  end

  def self.down
    drop_table :enrollments
  end
end
