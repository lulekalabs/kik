require File.dirname(__FILE__) + '/../test_helper'

class ContactTransactionTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    @advocate = people(:aaron)
  end

  def test_person_has_promotion_contact_transactions
    assert_equal [], @advocate.promotion_contact_transactions
  end

  def test_person_has_premium_contact_transactions
    assert_equal [], @advocate.premium_contact_transactions
  end
  
  def test_has_premium_contacts_count
    assert_equal 0, @advocate.premium_contacts_count
  end

  def test_has_promotion_contacts_count
    assert_equal 0, @advocate.promotion_contacts_count
  end
  
  def test_should_premium_contacts_count
    assert_difference "PremiumContactTransaction.count", 2 do 
      pretend_now_is Time.now.utc - 1.day do
        assert @advocate.premium_contact_transactions.create(:amount => 20)
        @advocate.reload
        assert_equal 20, @advocate.premium_contacts_count
        assert @advocate.premium_contact_transactions.create(:amount => -1)
        @advocate.reload
        assert_equal 19, @advocate.premium_contacts_count
        assert_equal 19, @advocate.total_contacts_count
      end
    end
  end

  def test_should_premium_contacts_count
    assert_difference "PremiumContactTransaction.count" do 
      pretend_now_is Time.now.utc - 31.day do
        assert @advocate.premium_contact_transactions.create(:amount => 20)
        @advocate.reload
      end
      assert_equal 0, @advocate.premium_contacts_count
    end
  end

  def test_should_promotion_contacts_count
    assert_difference "PromotionContactTransaction.count", 2 do 
      pretend_now_is Time.now.utc - 1.day do
        assert @advocate.promotion_contact_transactions.create(:amount => 100, :expires_at => Time.now.utc + 20.days)
        @advocate.reload
        assert_equal 100, @advocate.promotion_contacts_count
        assert @advocate.promotion_contact_transactions.create(:amount => -1)
        @advocate.reload
        assert_equal 99, @advocate.promotion_contacts_count
      end
    end
  end

  def test_should_not_promotion_contacts_count
    assert_difference "PromotionContactTransaction.count" do 
      pretend_now_is Time.now.utc - 31.day do
        assert @advocate.promotion_contact_transactions.create(:amount => 100, :expires_at => Time.now.utc + 30.days)
        @advocate.reload
      end
      assert_equal 0, @advocate.promotion_contacts_count
    end
  end
  
end
