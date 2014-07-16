# 20091007142132_update_people_add_professions.rb
class UpdatePeopleAddProfessions < ActiveRecord::Migration
  def self.up
    add_column :people, :profession_advocate, :boolean, :default => false
    add_column :people, :profession_mediator, :boolean, :default => false
    add_column :people, :profession_notary, :boolean, :default => false
    add_column :people, :profession_tax_accountant, :boolean, :default => false
    add_column :people, :profession_patent_attorney, :boolean, :default => false
    add_column :people, :profession_cpa, :boolean, :default => false
    add_column :people, :profession_affiant_accountant, :boolean, :default => false

    add_index :people, :profession_advocate
    add_index :people, :profession_mediator
    add_index :people, :profession_notary
    add_index :people, :profession_tax_accountant
    add_index :people, :profession_patent_attorney
    add_index :people, :profession_cpa
    add_index :people, :profession_affiant_accountant

  end

  def self.down
    remove_column :people, :profession_advocate
    remove_column :people, :profession_mediator
    remove_column :people, :profession_notary
    remove_column :people, :profession_tax_accountant
    remove_column :people, :profession_patent_attorney
    remove_column :people, :profession_cpa
    remove_column :people, :profession_affiant_accountant
  end
end
