class UpdateKasesAddingMissingFields < ActiveRecord::Migration
  def self.up
    add_column :kases, :summary, :string
    add_column :kases, :action_description, :string
    add_column :kases, :contract_period, :integer

    add_column :kases, :lat, :float
    add_column :kases, :lng, :float
  end

  def self.down
    remove_column :kases, :summary
    remove_column :kases, :action_description
    remove_column :kases, :contract_period
    
    remove_column :kases, :lat
    remove_column :kases, :lng
  end
end
