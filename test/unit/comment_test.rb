require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    @kase = create_kase
    assert_equal true, @kase.activate!
    assert_equal true, @kase.approve!
    assert @kase.expires_at
    @response = @kase.responses.create(:person => people(:homer), :description => "How about if you try this.")
    ActionMailer::Base.deliveries.clear
  end
  
  def test_should_deliver_notify_and_approving
    assert_difference "Comment.count" do
      assert_difference "Email.count" do
        @kase.comments.create(:person => @kase.person, :message => "Das verstehe ich jetzt nicht!")
        assert_equal 2, ActionMailer::Base.deliveries.size
      end
    end
  end

  def test_should_deliver_approved
    @comment = @kase.comments.create(:person => @kase.person, :message => "Das verstehe ich jetzt nicht!")
    ActionMailer::Base.deliveries.clear
    assert_difference "Email.count" do
      assert_equal true, @comment.approve!
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
  end

  def test_should_deliver_updated
    assert_difference "Response.count", 2 do
      r1 = @kase.responses.create(:person => people(:aaron), :description => "Erste Bewerbung")
      assert_equal true, r1.activate!
      r2 = @kase.responses.create(:person => people(:homer), :description => "Zweite Bewerbung")
      assert_equal true, r2.activate!
    end
    @comment = @kase.comments.create(:person => @kase.person, :message => "Das verstehe ich jetzt nicht!")
    ActionMailer::Base.deliveries.clear
    assert_difference "Email.count", 2 + 1 do
      assert_equal true, @comment.approve!
      assert_equal 3, ActionMailer::Base.deliveries.size
    end
  end
  
  def test_should_deliver_posted_by_client
    assert_difference "Comment.count", 1 do
      assert_difference "Email.count", 1 do
        comment = @response.comments.create(:person => @kase.person, :message => "Nochmal eine Nachfrage.")
        assert_equal true, comment.activate!
        assert_equal 1, ActionMailer::Base.deliveries.size
      end
    end
  end
  
end
