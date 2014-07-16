class AddNewFieldsInPeaople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :rescue_phone_number, :anglo_title_type
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :rescue_phone_number, :anglo_title_type
    end
  end
end