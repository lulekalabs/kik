class UpdatePeopleWithContactInfo < ActiveRecord::Migration
  def self.up
    add_column :people, :skype_name, :string
    add_column :people, :twitter_name, :string
    add_column :people, :facebook_name, :string
    add_column :people, :xing_name, :string
    add_column :people, :linkedin_name, :string

    add_column :people, :company_office_hours, :string
    add_column :people, :company_parking_lots, :string
    add_column :people, :company_taxi_stands, :string
    add_column :people, :company_public_transportation, :string
    add_column :people, :company_additional_location_information, :string
  end

  def self.down
    remove_column :people, :skype_name
    remove_column :people, :twitter_name
    remove_column :people, :facebook_name
    remove_column :people, :xing_name
    remove_column :people, :linkedin_name

    remove_column :people, :company_office_hours
    remove_column :people, :company_parking_lots
    remove_column :people, :company_taxi_stands
    remove_column :people, :company_public_transportation
    remove_column :people, :company_additional_location_information
  end
end
