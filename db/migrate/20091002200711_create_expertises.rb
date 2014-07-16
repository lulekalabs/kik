# 20091002200711
class CreateExpertises < ActiveRecord::Migration
  def self.up
    create_table :expertises do |t|
      t.column :name, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :expertises
  end
end
