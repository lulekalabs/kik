class UpdateArticlesChangeColumnLawArticle < ActiveRecord::Migration
  def self.up
    rename_column :articles, :article, :law_article
  end

  def self.down
    rename_column :articles, :law_article, :article
  end
end
