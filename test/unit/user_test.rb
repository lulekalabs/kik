require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :all

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_valid_advocate_user
    assert_difference 'User.count' do
      assert_difference 'Advocate.count' do
        user = create_advocate_user
        assert_equal :pending, user.current_state
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
        user.reload
        assert_equal "mighty-quire", user.login
      end
    end
  end

  def test_should_generate_valid_advocate_user_login
    assert_difference 'User.count', 2 do
      assert_difference 'Advocate.count', 2 do
        u1 = create_advocate_user({:email=> "j1@f.tst", :email_confirmation => "j1@f.tst"}, 
          {:first_name => "Özmür", :last_name => "Feßlmeier", :academic_title => academic_titles(:prof_dr)})
        u2 = create_advocate_user({:email=> "j2@f.tst", :email_confirmation => "j2@f.tst"}, 
          {:first_name => "Özmür", :last_name => "Feßlmeier", :academic_title => academic_titles(:prof_dr)})
        
        u1.reload
        u2.reload
        assert_equal "prof-dr-oezmuer-fesslmeier", u1.login
        assert_equal "prof-dr-oezmuer-fesslmeier-02", u2.login
      end
    end
  end

  def xtest_should_not_create_invalid_advocate_user
    assert_no_difference 'User.count' do
      assert_no_difference 'Advocate.count' do
        user = create_advocate_user(valid_user_attributes, invalid_advocate_attributes)
        assert !user.person.valid?, "#{user.person.errors.full_messages.to_sentence}"
        assert !user.valid?, "#{user.errors.full_messages.to_sentence}"
        assert user.person.business_address.errors.on(:street_number), "should require street number"
      end
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_and_start_in_passive_state
    user = create_user
    user.reload
    assert user.pending?
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user({:login => nil, :email => nil, :persist => true}, {:type => "Client"})
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count', 0 do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@test.tst', 'new password')
  end

  def test_should_not_rehash_password
    user = users(:quentin)
    user.update_attributes(:login => 'quentin2@test.tst')
    user.reload
    assert_equal users(:quentin), User.authenticate('quentin2@test.tst', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@test.tst', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_register_passive_user
    user = create_user(:password => nil, :password_confirmation => nil)
    assert user.passive?
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    user.register!
    assert user.pending?
  end

  def test_should_suspend_user
    users(:quentin).suspend!
    assert users(:quentin).suspended?
  end

  def test_suspended_user_should_not_authenticate
    users(:quentin).suspend!
    assert_not_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_unsuspend_user_to_active_state
    users(:quentin).suspend!
    assert users(:quentin).suspended?
    users(:quentin).unsuspend!
    assert users(:quentin).active?
  end

  def test_should_unsuspend_user_with_nil_activation_code_and_activated_at_to_passive_state
    users(:quentin).suspend!
    User.update_all :activation_code => nil, :activated_at => nil
    assert users(:quentin).suspended?
    users(:quentin).reload.unsuspend!
    assert users(:quentin).passive?
  end

  def test_should_unsuspend_user_with_activation_code_and_nil_activated_at_to_pending_state
    users(:quentin).suspend!
    User.update_all :activation_code => 'foo-bar', :activated_at => nil
    assert users(:quentin).suspended?
    users(:quentin).reload.unsuspend!
    assert users(:quentin).pending?
  end

  def test_should_delete_user
    assert_nil users(:quentin).deleted_at
    users(:quentin).delete!
    assert_not_nil users(:quentin).deleted_at
    assert users(:quentin).deleted?
  end

  def test_should_confirm_advocate_user_preapproved
    assert_difference 'User.count' do
      assert_difference 'Advocate.count' do
        user = create_advocate_user
        assert_equal :pending, user.current_state
        assert_equal 1, ActionMailer::Base.deliveries.size
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
        
        Project.pre_launch = true
        user.confirm!
        assert_equal :preapproved, user.current_state
        assert_equal 2, ActionMailer::Base.deliveries.size
      end
    end
  end

  protected

  def valid_user_attributes(options={})
    {
      :email => 'quire@example.com',
      :email_confirmation => 'quire@example.com',
      :password => 'quire',
      :password_confirmation => 'quire'
    }.merge(options)
  end

  def valid_person_attributes(options={})
    {
      :first_name => "Mighty",
      :last_name => "Quire",
      :gender => 'm',
      :phone_number => '+49 89 123456'
    }.merge(options)
  end

  def valid_advocate_attributes(options={})
    {
      :first_name => "Mighty",
      :last_name => "Quire",
      :gender => 'm',
      :phone_number => '+49 89 123456',
      :bar_association => bar_associations(:bamberg),
      :company_name => "Rechtsanwaltskanzlei Frauen",
      :company_url => "http://www.rechtsanwälte-frauen.tst",
      :newsletter => true,
      :profession_advocate => true,
      :profession_notary => true,
      :profession_cpa => true,
      :business_address_attributes => {
        :street => "Frauenstrasse",
        :street_number => "12",
        :city => "Bamberg",
        :postal_code => "96047",
        :country_code => "DE"
      }
    }.merge(options)
  end

  def invalid_advocate_attributes(options={})
    {
      :first_name => "Mighty",
      :last_name => "Quire",
      :gender => 'm',
      :phone_number => '+49 89 123456',
      :bar_association => bar_associations(:bamberg),
      :company_name => "Rechtsanwaltskanzlei Frauen",
      :company_url => "http://www.rechtsanwälte-frauen.tst",
      :newsletter => true,
      :profession_advocate => true,
      :profession_notary => true,
      :profession_cpa => true,
      :business_address_attributes => {
        :street => "Frauenstrasse",
#        :street_number => "12",
        :city => "Bamberg",
        :postal_code => "96047",
        :country_code => "DE"
      }
    }.merge(options)
  end

  def xcreate_user(user_options = {}, person_options={})
    record = User.new(valid_user_attributes(user_options))
    record.person.attributes = valid_person_attributes(person_options)
    record.register! if record.valid?
    record
  end

  def xcreate_advocate_user(user_options = {}, person_options={})
    record = User.new(valid_user_attributes(user_options))
    record.person = Advocate.new(valid_advocate_attributes(person_options))
    record.attributes = valid_user_attributes(user_options)
    record.save
    record.register! if record.valid?
    record
  end

  def xcreate_client_user(user_options = {}, person_options={})
    record = User.new(valid_user_attributes(user_options))
    record.person = Client.new(valid_client_attributes(person_options))
    record.attributes = valid_user_attributes(user_options)
    record.save
    record.register! if record.valid?
    record
  end

  
end
