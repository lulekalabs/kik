require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    Person.default_fields = {}
  end

  def teardown
    Person.default_fields = {}
  end

  def test_simple_new
    assert Person.new, "should instantiate"
  end
  
  def test_client_new
    assert_equal "Client", Client.new.class.name
  end

  def test_advocate_new
    assert_equal "Advocate", Advocate.new.class.name
  end
  
  def test_should_load_advocate
    homer = people(:homer)
    assert_equal "Advocate", homer.class.name
    assert_equal "Homer", homer.first_name
    assert_equal "Simpson", homer.last_name
    assert_equal "homer@test.tst", homer.email
    assert_equal "+49 (89) 999 9999", homer.phone_number
    assert_equal "m", homer.gender
    assert_equal academic_titles(:prof_dr), homer.academic_title
    assert_equal "Rechtsanwaltskanzlei Homer Simpson", homer.company_name
    assert_equal "http://www.simpsons.tst", homer.company_url
    assert_equal "Marge's Magazin", homer.referral_source
    assert_equal bar_associations(:bamberg), homer.bar_association
    assert_equal expertises(:arbeitsrecht), homer.primary_expertise
    assert_equal expertises(:agrarrecht), homer.secondary_expertise
  end

  def test_should_build_client
    client = build_client
    assert_equal true, client.valid?, client.errors.full_messages
  end

  def test_should_create_client
    assert_difference "Client.count" do
      assert_difference "ClientEnrollment.count" do
        client = create_client
      end
    end
  end
  
  def test_should_not_create_client_enrollment
    assert_difference "Client.count" do
      assert_no_difference "ClientEnrollment.count" do
        client = create_client({:newsletter => false})
        assert_equal client.enrollment, client.enrollments.first
      end
    end
  end
  
  def test_should_assign_enrollment_to_client
    assert_difference "Enrollment.count" do
      assert_difference "Client.count" do
        enrollment = create_enrollment({:type => ClientEnrollment})
        enrollment.register!
      
        client = create_client({:first_name => "Sepperl", :last_name => "Meier", :email => "sepp@meier.tst",
          :newsletter => true})
          
        client.reload
        
        assert_equal :active, client.enrollment.current_state
        assert_equal ClientEnrollment, client.enrollment.class
        assert_equal "Sepperl", client.enrollment.first_name
      end
    end
  end

  def test_should_not_assign_enrollment_to_client
    assert_difference "Enrollment.count", 2 do
      assert_difference "Client.count" do
        enrollment = create_enrollment({:type => AdvocateEnrollment})
        enrollment.register!
      
        client = create_client({:first_name => "Sepperl", :last_name => "Meier", :email => "sepp@meier.tst",
          :newsletter => true})
          
        client.reload
        
        assert_equal ClientEnrollment, client.enrollment.class
        assert_equal "Sepperl", client.enrollment.first_name
      end
    end
  end
  
  def test_should_build_advocate
    advocate = build_advocate
    assert_equal true, advocate.valid?, advocate.full_messages
  end
  
  def test_should_create_advocate
    assert_difference "Advocate.count" do
      assert_difference "AdvocateEnrollment.count" do
        advocate = create_advocate
      end
    end
  end

  def test_should_not_create_advocate_enrollment
    assert_difference "Advocate.count" do
      assert_no_difference "AdvocateEnrollment.count" do
        advocate = create_advocate({:newsletter => false})
      end
    end
  end
  
  def test_default_fields
    set_default_fields    
    person = Person.new :phone_number => "123456789"
    
    assert_equal "enter your first name*", person.first_name
    assert_equal "enter your last name*", person.last_name
    assert_equal "123456789", person.phone_number
  end
  
  def test_validate_default_fields
    set_default_fields    
    person = Person.new
    
    assert !person.valid?, "should not be valid"
    assert person.errors.on(:first_name)
    assert person.errors.on(:last_name)
    assert person.errors.on(:phone_number)
    
    assert_equal "enter your first name*", person.first_name
    assert_equal "enter your last name*", person.last_name
    assert_equal "enter your phone number*", person.phone_number
  end

  def test_default_fields_with_attributes
    set_default_fields    
    person = Person.new
    
    assert !person.valid?, "should not be valid"
    
    person.attributes = {
      :first_name => "Henry",
      :last_name => "Kissinger"
    }
    
    assert_equal "Henry", person.first_name
    assert_equal "Kissinger", person.last_name
    assert_equal "enter your phone number*", person.phone_number
  end

  def test_save_default_fields
    assert_difference "Person.count" do 
      set_default_fields    
      person = Person.new({
        :gender => "f",
        :first_name => "Henry",
        :last_name => "Kissinger",
        :phone_number => "123456789"
      })
    
      assert person.valid?, "should be valid"
      
      assert person.save, "should save"

      person = Person.find_by_id person.id
      
      assert_equal "Henry", person.first_name
      assert_equal "Kissinger", person.last_name
      assert_equal "123456789", person.phone_number
    end
  end
  
  def test_should_validate_validate_advocate
    assert_difference "Advocate.count" do
      Advocate.create(valid_advocate_attributes)
    end
  end
  
  def test_salutation_and_title_and_last_name
    assert_equal "Herr Prof. Dr. Simpson", people(:homer).salutation_and_title_and_last_name
  end

  def test_notifier_salutation_and_title_and_last_name
    assert_equal "Sehr geehrter Herr Prof. Dr. Simpson", people(:homer).notifier_salutation_and_title_and_last_name
    assert_equal "Sehr geehrte Frau Prof. Schweizer", people(:aaron).notifier_salutation_and_title_and_last_name
  end

  def test_should_gender_male_female
    assert_equal true, people(:homer).male?
    assert_equal false, people(:homer).female?
    assert_equal true, people(:aaron).female?
    assert_equal false, people(:aaron).male?
  end

  def test_create_journalist
    assert_difference "Journalist.count" do
      assert_difference "JournalistEnrollment.count" do
        journalist = create_journalist({
          :press_release_per_email => true,
          :press_release_per_fax => true,
          :press_release_per_mail => true,
        })
        assert_equal true, journalist.enrollment.press_release_per_email
        assert_equal true, journalist.enrollment.press_release_per_fax
        assert_equal true, journalist.enrollment.press_release_per_mail
      end
    end
  end
  
  def test_should_not_create_journalist_enrollment
    assert_difference "Journalist.count" do
      assert_no_difference "JournalistEnrollment.count" do
        journalist = create_journalist({:newsletter => false})
      end
    end
  end

  def test_name_and_email
    p1 = Person.new(:first_name => "Sepp", :last_name => "Meier", :email => "sepp@meier.com")
    assert_equal "Sepp Meier <sepp@meier.com>", p1.name_and_email
    p2 = Person.new(:first_name => "Sepp", :last_name => "Meier", :email => "Sepp Meier <sepp@meier.com>")
    assert_equal "Sepp Meier <sepp@meier.com>", p2.name_and_email
    p3 = Person.new(:email => "Sepp Meier <sepp@meier.com>")
    assert_equal "sepp@meier.com", p3.name_and_email
  end

  protected
  
  def set_default_fields
    Person.default_fields = {
      :first_name => "enter your first name*",
      :last_name => "enter your last name*",
      :phone_number => "enter your phone number*"
    }
  end
  
  def reset_default_fields(options={})
    Person.default_fields = options
  end

end
