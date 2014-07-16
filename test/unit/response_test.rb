require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    @kase = create_kase
    @response = @kase.responses.create(:person => people(:homer), :description => "How about if you try this.")
    ActionMailer::Base.deliveries.clear
  end
  
  def test_should_deliver_received
    assert_difference "Email.count" do
      assert_equal :created, @response.current_state
      assert_equal true, @response.activate!
      assert_equal :open, @response.current_state
      assert_equal 1, ActionMailer::Base.deliveries.size
      assert_equal @response.kase.person, Email.first.receiver
    end
  end
  
  def test_should_deliver_read
    assert_difference "Email.count" do
      assert_difference "Reading.count" do
        @response.read_by!(people(:aaron))
        assert_equal 1, ActionMailer::Base.deliveries.size
      end
    end
  end

end
