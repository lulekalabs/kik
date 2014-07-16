# 20091028134247_update_kases_add_sender_info
class UpdateKasesAddSenderInfo < ActiveRecord::Migration
  def self.up
    add_column :kases, :sender_email, :string
    add_column :kases, :sender_postal_code, :string
    add_column :kases, :sender_gender, :string, :limit => 1
    add_column :kases, :sender_first_name, :string
    add_column :kases, :sender_last_name, :string
    add_column :kases, :sender_city, :string
    add_column :kases, :sender_phone_number, :string
    add_column :kases, :sender_remedy_insured, :boolean, :default => false
    add_column :kases, :sender_newsletter, :boolean, :default => false

    add_index :kases, :sender_email
  end

  def self.down
    remove_column :kases, :sender_email
    remove_column :kases, :sender_postal_code
    remove_column :kases, :sender_gender
    remove_column :kases, :sender_first_name
    remove_column :kases, :sender_last_name
    remove_column :kases, :sender_city
    remove_column :kases, :sender_phone_number
    remove_column :kases, :sender_remedy_insured
    remove_column :kases, :sender_newsletter
  end
end
