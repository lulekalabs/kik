# 20091028130112_update_articles_update_types.rb
class UpdateArticlesUpdateTypes < ActiveRecord::Migration
  def self.up
    execute "UPDATE articles SET type = NULL, dictionary = 1 WHERE type = 'DictionaryEntry'"
  end

  def self.down
    execute "UPDATE articles SET type = 'DictionaryEntry' WHERE dictionary = 1"
  end
end
