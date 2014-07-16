require File.dirname(__FILE__) + '/../test_helper'

class QuestionsControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  def test_should_get_new
    get :new
    assert_response :success
    assert assigns(:kase)
    assert assigns(:user)
    assert assigns(:person)
    assert assigns(:address)
  end

  def test_should_post_new
    post :new, :kase => {:description => "Forwarded from home page"}
    assert_response :success
    assert @kase = assigns(:kase)
    assert_equal "Forwarded from home page", @kase.description
  end

  def test_should_post_create
    assert_difference "Kase.count" do
      assert_difference "User.count" do
        assert_difference "Person.count" do
          assert_difference "PersonalAddress.count" do
            post :create, {"person"=>{"personal_address_attributes"=>
              {"city"=>"München", "postal_code"=>"80469", "street"=>"Dreimühlenstr.", "street_number"=>"21"}, 
                "remedy_insured"=>"1", "gender"=>"m", "phone_number"=>"089/1234567", "academic_title_id"=>"11", 
                  "newsletter"=>"1", "last_name"=>"Bepperl", "first_name"=>"Sepperl"}, 
                    "user"=>{"email_confirmation"=>"sepperl@bepperl.com", "terms_of_service"=>"1", "login"=>"sepperl", "email"=>"sepperl@bepperl.com"}, 
                      "kase"=>{"contract_period"=>"10", "postal_code"=>"10040", "summary"=>"Kurzbeschreibung", "description"=>"Beschreibung", "action_description"=>"Was zum T. ist passiert in der Angelegenheit...noch nichts natürlich."}}
            assert_response :redirect
            assert @kase = assigns(:kase)
            assert_equal true, @kase.valid?
            assert_equal :created, @kase.current_state

            assert @user = assigns(:user)
            assert_equal true, @user.valid?
            assert_equal :pending, @user.current_state

            assert_redirected_to confirm_question_path(@kase)
            
            assert_equal 1, ActionMailer::Base.deliveries.size
          end
        end
      end
    end
  end
  
end
