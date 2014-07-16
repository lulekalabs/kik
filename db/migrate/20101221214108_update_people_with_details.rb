class UpdatePeopleWithDetails < ActiveRecord::Migration
  def self.up
    add_column :people, :bio, :text
    add_column :people, :anglo_title, :string
    add_column :people, :position_name, :string
    add_column :people, :accredited_on, :date
    add_column :people, :occupational_title, :string
    add_column :people, :authorized_representative, :string
    add_column :people, :professional_indemnity, :string
    add_column :people, :company_information, :text
    add_column :people, :company_locations, :text
    
    add_column :people, :logo_file_name, :string
    add_column :people, :logo_content_type, :string
    add_column :people, :logo_file_size, :integer
    add_column :people, :logo_updated_at, :datetime
  end

  def self.down
    remove_column :people, :bio
    remove_column :people, :anglo_title
    remove_column :people, :position_name
    remove_column :people, :accredited_on
    remove_column :people, :occupational_title
    remove_column :people, :authorized_representative
    remove_column :people, :professional_indemnity
    remove_column :people, :company_information
    remove_column :people, :company_locations
    
    remove_column :people, :logo_file_name
    remove_column :people, :logo_content_type
    remove_column :people, :logo_file_size
    remove_column :people, :logo_updated_at
  end
end
