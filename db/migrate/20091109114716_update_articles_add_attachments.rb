# 20091109114716_update_articles_add_attachments.rb
class UpdateArticlesAddAttachments < ActiveRecord::Migration
  def self.up
    add_column :articles, :primary_attachment_file_name,    :string
    add_column :articles, :primary_attachment_content_type, :string
    add_column :articles, :primary_attachment_file_size,    :integer
    add_column :articles, :primary_attachment_updated_at,   :datetime

    add_column :articles, :secondary_attachment_file_name,    :string
    add_column :articles, :secondary_attachment_content_type, :string
    add_column :articles, :secondary_attachment_file_size,    :integer
    add_column :articles, :secondary_attachment_updated_at,   :datetime
  end

  def self.down
    remove_column :articles, :primary_attachment_file_name
    remove_column :articles, :primary_attachment_content_type
    remove_column :articles, :primary_attachment_file_size
    remove_column :articles, :primary_attachment_updated_at

    remove_column :articles, :secondary_attachment_file_name
    remove_column :articles, :secondary_attachment_content_type
    remove_column :articles, :secondary_attachment_file_size
    remove_column :articles, :secondary_attachment_updated_at
  end
end
