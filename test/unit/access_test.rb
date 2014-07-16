require File.dirname(__FILE__) + '/../test_helper'

class AccessTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    @advocate = people(:aaron)
    @client = people(:quentin)
    @kase = create_question
  end

  def test_should_create
    assert_difference "Access.count" do
      pretend_now_is Time.now.utc - 2.day do
        assert @advocate.premium_contact_transactions.create(:amount => 1)
        @advocate.reload
        assert_equal 1, @advocate.premium_contacts_count
      end
      pretend_now_is Time.now.utc - 1.day do
        assert Access.create(:requestor => @advocate, :requestee => @client, :accessible => @kase)
      end
      @advocate.reload
      assert_equal 0, @advocate.total_contacts_count
    end
  end

  def test_should_not_create
    assert_no_difference "Access.count" do
      assert Access.create(:requestor => @advocate, :requestee => @client, :accessible => @kase)
    end
  end
  
  def test_should_access_to
    assert_difference "Access.count" do
      pretend_now_is Time.now.utc - 2.day do
        assert @advocate.premium_contact_transactions.create(:amount => 1)
        @advocate.reload
        assert_equal 1, @advocate.premium_contacts_count
      end
      pretend_now_is Time.now.utc - 1.day do
        assert_equal true, @advocate.access_to!(@kase)
        assert_equal true, @advocate.access_to?(@kase)
      end
      @advocate.reload
      assert_equal 0, @advocate.total_contacts_count
    end
  end

  def test_should_access_to_one_time_only
    assert_difference "Access.count" do
      pretend_now_is Time.now.utc - 2.day do
        assert @advocate.premium_contact_transactions.create(:amount => 2)
        @advocate.reload
        assert_equal 2, @advocate.premium_contacts_count
      end
      pretend_now_is Time.now.utc - 1.day do
        assert_equal false, @advocate.access_to?(@kase)
        assert_equal true, @advocate.access_to!(@kase)
        assert_equal true, @advocate.access_to?(@kase)
        assert_equal false, @advocate.access_to!(@kase)
      end
      @advocate.reload
      assert_equal 1, @advocate.total_contacts_count
    end
  end
  

end
