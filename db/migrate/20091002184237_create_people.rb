# 20091002184237
class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :type, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :phone_number, :string
      t.column :gender, :string, :limit => 1
      t.timestamps

      #--- clients only
      t.column :remedy_insured, :boolean, :default => false
      t.column :newsletter, :boolean, :default => false
      
      #--- advocates only
      t.column :bar_association_id, :integer
      t.column :title, :string
      t.column :company_url, :string
      t.column :company_name, :string
      t.column :referral_source, :text
    end
    
    add_index :people, :bar_association_id
  end

  def self.down
    drop_table :people
  end
end
