require File.dirname(__FILE__) + '/../test_helper'

class KaseTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    ActionMailer::Base.deliveries.clear
    GeoKit::Geocoders::MultiGeocoder.stubs(:geocode).returns(valid_geo_location)
  end
  
  def test_should_create
    assert_difference "Question.count" do
      create_kase
    end
  end

  def test_should_change_states
    kase = create_question
    assert_equal :created, kase.current_state, "should be created"
    assert_not_nil kase.created_at
    
    assert_equal true, kase.activate!, "should activate"
    assert_equal :preapproved, kase.current_state, "should be preapproved"
    assert_not_nil kase.preapproved_at

    assert_equal true, kase.approve!, "should approve"
    assert_equal :open, kase.current_state, "should be open"
    assert_not_nil kase.opened_at

    assert_equal true, kase.cancel!, "should cancel"
    assert_equal :closed, kase.current_state, "should be closed"
    assert_not_nil kase.closed_at
  end

  def test_should_send_activation
    assert_difference "User.count" do
      assert_difference "Client.count" do
        assert_difference "PersonalAddress.count" do
          assert_difference "Question.count" do
            kase = create_question_with_new_client_user
            assert_equal 1, ActionMailer::Base.deliveries.size
            assert kase.activation_code, "should create activation code"
            assert_equal true, ActionMailer::Base.deliveries.first.body.include?(kase.activation_code)
          end
        end
      end
    end
  end

  def test_should_activate_with_new_user
    kase = create_question_with_new_client_user
    assert_equal true, kase.activate!, "should activate"
    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_equal true, kase.person.user.password_is_generated
    assert password = kase.person.user.password, "should temporarely store password"
    assert kase.person.user.salt, "should create password salt"
    assert_equal true, ActionMailer::Base.deliveries[1].body.include?("Benutzername")
    assert_equal true, ActionMailer::Base.deliveries[1].body.include?(kase.person.user.password)
    assert User.authenticate(kase.person.user.login, kase.person.user.password), "should authenticate with generated password"
  end

  def test_should_geocode
    assert_difference "Question.count" do
      kase = create_question(:postal_code => "80469")
      assert_equal "80469", kase.postal_code
      assert_equal true, kase.geo_coded?
      assert_equal 37.720592, kase.lat
      assert_equal -122.443287, kase.lng
    end
  end
  
  def test_should_set_expires_at
    assert_difference "Question.count" do
      kase = create_question(:contract_period => 3)
      assert_nil kase.expires_at, "should not have an expiry date"
      assert_equal 3, kase.contract_period
      assert_equal true, kase.activate!, "should activate"
      assert kase.expires_at, "should have an expiry date"
      assert kase.expires_at > Time.now.utc + 3.days - 1.second &&
        kase.expires_at < Time.now.utc + 3.days + 1.second
    end
  end
  
  def test_should_deliver_closed
    kase = create_active_question
    r1 = kase.responses.create(:person => people(:homer), :description => "Was für eine super Frage!")
    assert_equal true, r1.activate!
    r2 = kase.responses.create(:person => people(:aaron), :description => "Jetzda kommt noch eine ganz tolle")
    assert_equal true, r2.activate!
    assert_difference "Email.count", 3 do
      assert_equal true, kase.cancel!
    end
  end
  
  protected
  
  def create_question_with_new_client_user(kase_options={}, user_options={}, person_options={})
    user = build_client_user(valid_client_user_attributes(user_options), valid_client_attributes(person_options))
    kase = build_question(:person => user.person)
    user.register!
    kase.save!
    kase
  end
  
  def create_active_question
    kase = create_question
    kase.activate!
    kase.approve!
    assert_equal :open, kase.current_state
    kase
  end
  
end
