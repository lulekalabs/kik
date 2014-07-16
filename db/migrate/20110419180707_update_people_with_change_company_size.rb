class UpdatePeopleWithChangeCompanySize < ActiveRecord::Migration
  def self.up
    change_column :people, :company_size, :integer
  end

  def self.down
    change_column :people, :company_size, :string
  end
end
