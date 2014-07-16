class UpdatePeopleWithMoreCompanyInfo < ActiveRecord::Migration
  def self.up
    add_column :people, :company_size, :string
    add_column :people, :company_type, :string
    add_column :people, :company_headquarter, :string
  end

  def self.down
    remove_column :people, :company_size
    remove_column :people, :company_type
    remove_column :people, :company_headquarter
  end
end
