require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures :all

  ROOT = File.join(File.dirname(__FILE__), '..')
  
  def test_should_create
    assert_difference "Asset.count" do 
      Asset.create(valid_asset_attributes)
    end
  end
  
  def test_should_create_file
    asset = build_asset
    asset.file = File.new(File.join(ROOT, "fixtures", "files", "test.jpg"), 'rb')
    assert asset.save, "should save"
    assert asset.file.file?, "should have file attached"
    assert asset.file(:thumb).match("thumb_test.jpg"), "should attach thumb"
    assert asset.file(:profile).match("profile_test.jpg"), "should attach profile"
    assert asset.file(:article).match("article_test.jpg"), "should attach article"
  end
  
  def test_should_assign_person_from_assetable
    assert_difference "Question.count" do 
      kase = create_question
      asset = build_asset(:person => nil)
      assert_equal kase.person, asset.person, "should assign kase's person"
    end
  end

  def test_should_not_assign_person_from_assetable
    assert_difference "Question.count" do 
      kase = create_question
      asset = build_asset(:person => people(:homer))
      assert_not_equal kase.person, asset.person, "should not assign kase's person"
      assert_equal people(:homer), asset.person
    end
  end

end
