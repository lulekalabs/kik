# 20091026165417_create_kases.rb
class CreateKases < ActiveRecord::Migration
  def self.up
    create_table :kases do |t|
      t.column :person_id, :integer
      t.column :type, :string
      t.column :status, :string, :default => "created"
      t.column :description, :text
      t.timestamps
    end
    
    add_index :kases, :person_id
    add_index :kases, :type
    add_index :kases, :status
  end

  def self.down
    drop_table :kases
  end
end
