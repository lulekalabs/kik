require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :all

  ROOT = File.join(File.dirname(__FILE__), '..')
  
  def test_should_create
    assert_difference "Article.count" do 
      Article.create(valid_article_attributes)
    end
  end

  def test_should_not_create
    assert_no_difference "Article.count" do 
      Article.create(valid_article_attributes(:person => nil))
    end
  end
    
  def test_should_create_image
    article = build_article
    article.image = File.new(File.join(ROOT, "fixtures", "files", "test.jpg"), 'rb')
    assert article.save, "should save"
    assert article.image.file?, "should have image attached"
    assert article.image(:thumb).match("thumb_test.jpg"), "should attach thumb"
    assert article.image(:profile).match("profile_test.jpg"), "should attach profile"
    assert article.image(:article).match("article_test.jpg"), "should attach article"
  end

  def test_should_create_primary_attachment_with_msword_file
    article = build_article
    article.primary_attachment = File.new(File.join(ROOT, "fixtures", "files", "test.doc"), 'rb')
    assert article.save, "should save"
    assert article.primary_attachment.file?, "should have attachment attached"
  end

  def test_should_create_secondary_attachment_with_pdf_file
    article = build_article
    article.secondary_attachment = File.new(File.join(ROOT, "fixtures", "files", "test.pdf"), 'rb')
    assert article.save, "should save"
    assert article.secondary_attachment.file?, "should have attachment attached"
  end

  def test_should_create_primary_attachment_with_msword_file
    article = build_article
    article.primary_attachment = File.new(File.join(ROOT, "fixtures", "files", "test.xls"), 'rb')
    assert article.save, "should save"
    assert article.primary_attachment.file?, "should have attachment attached"
  end
  
  protected
  
  def valid_article_attributes(options={})
    {
      :title => "Test Title",
      :body => "Here goes the test content",
      :person => people(:homer)
    }.merge(options)
  end
  
  def build_article(options={})
    Article.new(valid_article_attributes(options))
  end

  def create_article(options={})
    Article.create(valid_article_attributes(options))
  end
  
  def valid_asset_attributes(options={})
    {
      :name => "Test Asset",
      :url => "http://www.test.tst"
    }.merge(options)
  end
  
end
