ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha'
require 'test_help'
require File.expand_path(File.dirname(__FILE__) + "/authenticated_test_helper")

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

#--- helpers

def valid_user_attributes(options={})
  {
    :email => 'quire@example.com',
    :email_confirmation => 'quire@example.com',
    :password => 'quire',
    :password_confirmation => 'quire'
  }.merge(options)
end

def valid_client_user_attributes(options={})
  {
    :persist => false,
    :login => 'newbie',
    :email => 'newbie@example.com',
    :email_confirmation => 'newbie@example.com',
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

def valid_client_attributes(options={})
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
    :academic_title => academic_titles(:prof_dr),
    :phone_number => '+49 89 123456',
    :bar_association => bar_associations(:bamberg),
#    :primary_expertise => topics(:arbeitsrecht),
#    :secondary_expertise => topics(:agrarrecht),
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

def create_user(user_options = {}, person_options={})
  record = User.new(valid_user_attributes(user_options))
  record.person = Person.new(valid_person_attributes(person_options).merge(:user => record))
  record.attributes = valid_user_attributes(user_options)
  record.register! if record.valid?
  record
end

def create_advocate_user(user_options = {}, person_options={})
  record = User.new(valid_user_attributes(user_options))
  record.person = Advocate.new(valid_advocate_attributes(person_options).merge(:user => record))
  record.attributes = valid_user_attributes(user_options)
  record.register! if record.valid?
  record
end

def create_client_user(user_options = {}, person_options={})
  record = User.new(valid_user_attributes(user_options))
  record.person = Client.new(valid_client_attributes(person_options).merge(:user => record))
  record.attributes = valid_user_attributes(user_options)
  record.register! if record.valid?
  record
end

def build_client_user(user_options = {}, person_options={})
  record = User.new(valid_client_user_attributes(user_options))
  record.person = Client.new(valid_client_attributes(person_options))
  record.attributes = valid_client_user_attributes(user_options)
  # record.register! if record.valid?
  record
end

def valid_client_attributes(options={})
  {
    :first_name => "Test First Name",
    :last_name => "Test Last Name",
    :email => "quentin@test.tst",
    :phone_number => "+49 (89) 123 4567",
    :gender => "m",
    :newsletter => true,
    :remedy_insured => true,
    :personal_address_attributes => {
      :street => "Männerstrasse",
      :street_number => "99",
      :city => "Ulm",
      :postal_code => "76543",
      :country_code => "DE"
    }
  }.merge(options)
end

def build_client(options={})
  Client.new valid_client_attributes(options)
end

def create_client(options={})
  Client.create valid_client_attributes(options)
end

def build_advocate(options={})
  Advocate.new valid_advocate_attributes(options)
end

def create_advocate(options={})
  Advocate.create valid_advocate_attributes(options)
end

def valid_journalist_attributes(options={})
  {
    :first_name => "James",
    :last_name => "Journ",
    :gender => 'm',
    :academic_title => academic_titles(:prof_dr),
    :phone_number => '+49 1234567',
    :fax_number => '+49 1234568',
    :company_name => "Der Spiegel",
    :company_url => "http://www.spiegel.de",
    :media => "Internet",
    :newsletter => true,
    :email => "james.journ@test.tst",
    :email_confirmation => "james.journ@test.tst",
    :press_release_per_email => true,
    :press_release_per_fax => true,
    :press_release_per_mail => true,
    :business_address_attributes => {
      :street => "Frauenstrasse",
      :street_number => "12",
      :city => "Bamberg",
      :postal_code => "96047",
      :country_code => "DE"
    }
  }.merge(options)
end

def build_journalist(options={})
  Journalist.new valid_journalist_attributes(options)
end

def create_journalist(options={})
  Journalist.create valid_journalist_attributes(options)
end

#--- article 

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

#--- asset 

def valid_asset_attributes(options={})
  {
    :assetable => articles(:blog),
    :name => "Test Asset",
    :url => "http://www.test.tst"
  }.merge(options)
end

def build_asset(options={})
  Asset.new(valid_asset_attributes(options))
end

def create_asset(options={})
  Asset.create(valid_asset_attributes(options))
end

#--- enrollment

def valid_enrollment_attributes(options={})
  {
    :type => ClientEnrollment,
    :gender => "m",
    :first_name => "Sepp",
    :last_name => "Meier",
    :email => "sepp@meier.tst",
    :email_confirmation => "sepp@meier.tst",
    :academic_title => academic_titles(:prof_dr),
    :press_release_per_email => false,
    :press_release_per_fax => false,
    :press_release_per_mail => false
  }.merge(options)
end

def build_enrollment(options={})
  Enrollment.new(valid_enrollment_attributes(options))
end

def create_enrollment(options={})
  Enrollment.create(valid_enrollment_attributes(options))
end

#--- kase

def valid_kase_attributes(options={})
  {
    :person => people(:quentin),
    :description => "This is a valid question description.",
    :summary => "This is a valid question summary",
    :action_description => "So what I did is nothing in these matters.",
    :contract_period => 5,
    :postal_code => "80469",
    :type => "Question"
  }.merge(options)
end

def build_kase(options={})
  Kase.new(valid_kase_attributes(options))
end

def create_kase(options={})
  Kase.create(valid_kase_attributes(options))
end

def build_question(options={})
  Kase.new(valid_kase_attributes(options.merge(:type => "Question")))
end

def create_question(options={})
  Kase.create(valid_kase_attributes(options.merge(:type => "Question")))
end

#--- geokit
def valid_geo_location
  geoloc = GeoKit::GeoLoc.new(
    :street_address => '100 Rousseau St',
    :city => 'San Francisco',
    :zip => '94112',
    :country_code => 'US',
    :state => 'CA',
    :lat => 37.720592,
    :lng => -122.443287
  )
  geoloc.success = true
  geoloc
end

#--- review

def valid_review_attributes(options={})
  {
    :reviewer => people(:quentin),
    :reviewee => people(:aaron),
    :v => 2,
    :z => 3,
    :m => 1,
    :e => 1,
    :a => 2,
    :disqualification => "1"
  }.merge(options)
end
  
def build_review(options={})
  Review.new(valid_review_attributes(options))
end

def create_review(options={})
  Review.create(valid_review_attributes(options))
end

#--- time warp
# Extend the Time class so that we can offset the time that 'now'
# returns.  This should allow us to effectively time warp for functional
# tests that require limits per hour, what not.
Time.class_eval do 
  class << self
    attr_accessor :testing_offsets
    alias_method :real_now, :now
    
    def now
      real_now - (testing_offsets.sum || 0)
    end
    alias_method :new, :now
  end
end
Time.testing_offsets = []

# Time warp to the specified time for the duration of the passed block
def pretend_now_is(time)
  Time.testing_offsets.push(Time.now.utc - time.utc)
  yield
ensure
  Time.testing_offsets.pop
end
