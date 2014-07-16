# This class generates vouchers, by code (promotion code) and uuid, therefore, each 
# Voucher instance has a code and uuid. The kind (type) of voucher is entirely 
# dependent on what it is used for, e.g. :promotion, or :invitation, but it does
# not have influence on neither code nor uuid.
# The :uuid_base field indicates which of the attributes was used to generate
# the uuid. The :mac_address stores the equipment's mac address which was used to
# generate the uuid. The code (promotion code) is generated based as a random
# alpha non-case sensitive 12 digits (plus 2-dashes).
#
#  voucher types:
#    :invitation
#    :promotion
#    :other
#
# Examples:
#
#  Voucher.generate_bulk(100)
#
#  Voucher.save_to_csv( Voucher.find_all_from_batch )   # save to csv from current batch
#
#  Voucher.load_from_csv "vouchers.csv"                 # load csv file into vouchers table
#
#  Voucher.save_to_csv( Voucher.find_all_from_batch, :attributes => [ :code ] )
#
require "enumerator"
require 'csv'
class Voucher < ActiveRecord::Base
	include DefaultFields
  
  #--- constants
  EMAIL_REGEXP = /[\w-]+(?:\.[\w-]+)*@(?:[\w-]+\.)+[a-zA-Z]{2,7}$/

  #--- accessors
  attr_accessor :taxable
  attr_accessor :consignee_confirmation
  attr_accessor :validate_code_confirmation
  attr_accessor :validate_verification_code
  attr_accessor :code_confirmation

  attr_protected :code
  attr_protected :validate_verification_code

  #--- associations
  belongs_to :consignor, :class_name => 'Person', :foreign_key => :consignor_id  # sender, versender
  belongs_to :consignee, :class_name => 'Person', :foreign_key => :consignee_id  # recipient, empfänger
  belongs_to :promotable, :polymorphic => true  # product, product_line, etc.
  
  has_many :voucher_redemptions, :dependent => :destroy
  has_many :redeemers, :through => :voucher_redemptions, :source => :person
  
  #--- validations
  validates_uniqueness_of :uuid
  validates_email_format_of :email, :allow_nil => false, :allow_blank => false, :if => Proc.new {|o| o.uuid_base == :email}
  validates_presence_of :timestamp, :if => Proc.new {|o| o.uuid_base == :timestamp}
  validates_presence_of :uuid
  #validates_confirmation_of :code
  validates_presence_of :code_confirmation, :if => :validate_code_confirmation?

  #--- mixins
  money :price, :cents => :cents, :currency => :currency
  #acts_as_sellable
  
  #--- scopes
  named_scope :active, :conditions => ["vouchers.redeemed_at IS NULL AND vouchers.expires_at > ?", Time.now.utc]
  named_scope :expired, :conditions => ["vouchers.expires_at < ?", Time.now.utc]
  
  #--- callbacks

  before_create :write_expires_at, :generate_code
  before_validation_on_create :generate_uuid
  
  #--- class methods
  class << self
    
    # type casts to the class specified in :type parameter
    #
    # E.g.
    #
    #   d = DepositAccount.new(:type => PaypalDepositAccount)
    #   d.kind == :paypal  # -> true
    #
    def new_with_cast(*a, &b)  
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and 
        (k = type.class == Class ? type : (type.class == Symbol ? klass(type) : type.constantize)) != self
        raise 'type not descendent of Voucher' unless k < self || self < k   # klass should be a descendant of us  
        return k.new_without_cast(*a, &b)  
      end  
      new_without_cast(*a, &b)  
    end  
    alias_method_chain :new, :cast

    def klass(a_kind=nil)
      [PromotionContactVoucher].each do |subclass|
        return subclass if subclass.kind == a_kind
      end
      Voucher
    end

    def kind
      :promotion
    end
    
    def content_column_names
      content_columns.map(&:name) - %w(promotable_type)
    end
    
    # Get a new batch code, which is an ascending number to classify
    # the Voucher code generated in a batch by generate
    def get_new_batch_code
      transaction do
        if no = Voucher.get_current_batch_code
          no + 1
        else
          1
        end
      end
    end

    def get_current_batch_code
      if latest = Voucher.find(:first, :order => 'batch DESC', :lock => true)
        latest.batch.to_i
      else
        nil
      end
    end

    # Returns all vouchers from batch
    def find_all_from_batch(no=Voucher.get_current_batch_code)
      Voucher.find(:all, :conditions => ["batch = ?", no], :order => 'created_at ASC')
    end

    # Generate bulk series of voucher codes and asigns a batch value for them.
    # Returns batch value if run successfully.
    # Options:
    #   :quantity => 1..999
    #   voucher attributes
    #   :consignor => <person>  # sender
    #   :consignee => <person>  # receiver
    #   :email => o.email       # email of receiver
    #   :kind => currently only supports :partner_membership_promotion
    #   :promotable_sku => 'SU00100',
    #   :expires_at => Time.now.utc + 3.months )
    def generate(quantity, options={})
      defaults = {
        :type => :promotion,
        :batch => get_new_batch_code,
        :expires_at => Time.now.utc + 3.months
      }
      options = defaults.merge(options).symbolize_keys

      result = []
      quantity.times do 
        voucher = new(options)
        if voucher.valid?
          voucher.save
          result << voucher
        end
      end
      result
    end

    def save_to_csv(input, options={})
      defaults = {:attributes => content_attributes, :header => true, :delimiter => ';', :file_name => "vouchers.csv"}
      options = defaults.merge(options).symbolize_keys

      outfile = File.open(options[:file_name], 'wb')
      CSV::Writer.generate(outfile, options[:delimiter]) do |csv|
        csv << options[:attributes] if options[:header]
        input.each do |row|
          values = []
          Voucher.content_attributes.each { |column| values.push( row.send( column ) ) if options[:attributes].include?(column) && row.respond_to?( column ) }
          csv << values
        end
      end
      outfile.close
      true
    end

    def load_from_csv(file_name, options={})
      defaults = { :attributes => content_attributes, :delimiter => ';', :file_name => "vouchers.csv" }
      options = defaults.merge(options).symbolize_keys

      column_clause = nil
      is_header = false
      table_name="vouchers"

      cnx = ActiveRecord::Base.connection
      ActiveRecord::Base.silence do
  #      reader = CSV::Reader.create(data)

        reader = CSV::Reader.parse( File.open(file_name, 'rb'), options[:delimiter] )

        columns = reader.shift.map {|column_name| cnx.quote_column_name(column_name) }
        column_clause = columns.join(', ')

        reader.each do |row|
          next if row.first.nil? # skip blank lines
          raise "No table name defined" if !table_name
          raise "No header defined" if !column_clause
          values_clause = row.map {|v| cnx.quote(v).gsub('\\n', "\n").gsub('\\r', "\r") }.join(', ')
          sql = "INSERT INTO #{table_name} (#{column_clause}) VALUES (#{values_clause})"
          cnx.insert(sql)
        end
      end
    end

    def find_by_uuid_and_email(a_uuid, an_email)
      if UUID.parse( a_uuid ).valid? && !(an_email =~ EMAIL_REGEXP).nil?
        if voucher = find(:first, :conditions => ["uuid = ? AND uuid_base = ?", a_uuid, 'email'])
          return voucher
        end
      end
      nil
    end

    # overrides rails auto model method find_by_code to undasherize given code
    def find_by_code(a_code, options={})
      find(:first, :conditions => options.merge({:code => undasherize_code(a_code)})) if a_code
    end
    
    # used as code confirmation comes in parameterized attribute hash
    # finder also assigns user_confirmation to restrict (validate) that
    # an assigned voucher could not be used by another user
    def find_by_code_confirmation_attributes(attributes={}, person=nil)
      if voucher = find_by_code(new(attributes).code_confirmation)
        voucher.attributes = attributes
        voucher.consignee_confirmation = person if person && voucher.consignee?
        voucher
      end
    end

    # returns voucher if voucher can be found by code and valid? otherwise,
    # returns nil
    def redeem_by_code(a_code, consigning_user=nil)
      if voucher = find_by_code(a_code)
        if consigning_user && consigning_user.person &&
            voucher.consignee && voucher.consignee != consigning_user.person
          return nil
        end
        if voucher.valid?
          if !voucher.consignee && consigning_user && consigning_user.person
            voucher.update_attribute(:consignee, consigning_user.person)
          end
          return voucher if voucher.redeem!
        end
      end
    end

    # removes all dashes '-' from a voucher code string
    def undasherize_code(a_code)
      a_code.to_s.gsub('-', '')
    end

    # inserts the dashes of a given voucher code string
    def dasherize_code(a_code)
      (undasherize_code(a_code.to_s) + (' ' * 12)).insert(4, '-').insert(9, '-').strip
    end

    # inserts obfuscating 'X'es to the voucher code string
    def obfuscate_code(a_code)
      undasherize_code(a_code.to_s)[0..undasherize_code(a_code.to_s).length - 5] + ('*' * 4)
    end

  end
  
  #--- instance methods
  
  # writes default expirey in 3 months
  def write_expires_at
    self[:expires_at] ||= Time.now.utc + 3.month
  end

  # Generates and writes unique code (promotion code)
  # which will be a 12-digit (plus 2-dash) non-case-sensitive alpha code
  #
  # Examples:
  #    "abcd-efgh-ijkl"
  #    "tzxs-noox-asen"
  #
  def generate_code
    self[:code] = Array.new(12){(rand(26)+97).chr}.join
  end

  # Generates a uuid based on the given email or timestamp.
  # If non of these are given, a random uuid will be generated.
  # Each of the uuid is encoded with the MAC address which will
  # be stored under mac_address
  def generate_uuid
    if uuid_base.nil?
      if email?
        self.uuid_base = :email
      elsif timestamp?
        self.uuid_base = :timestamp
      else
        self.uuid_base = :random
      end
    end
    current_time = timestamp || Time.now.utc
    self[:timestamp] = current_time.to_f
    self[:uuid] = Project.generate_random_uuid
  end

  # returs true if the voucher has expired
  def expired?
    self.expires_at ? self.expires_at < Time.now.utc : false
  end

  # returns true if the voucher has been redeemed
  def redeemed?
    if self.multiple_redeemable
      self.anonymous? ? false : !!self.voucher_redemptions.find(:first, :conditions => ["voucher_redemptions.person_id = ?", self.consignee.id])
    else
      self.redeemed_at ? self.redeemed_at < Time.now.utc : false
    end
  end
  
  # returns an instance of a promotable product if one is assigned to this voucher
  # and caches the product instance for next access
  def promotable_product(locale=nil)
    return self.promotable if self.promotable
    if self.promotable_sku && (self.consignee || locale)
      locale_cache_key = locale ? locale : self.consignee.default_locale
      return (@promotable_product_cache || {})[locale_cache_key] if (@promotable_product_cache || {})[locale_cache_key]
      @promotable_product_cache = (@promotable_product_cache || {}).merge(Hash[locale_cache_key, Product.find_like_by_sku(
        self.promotable_sku,
        :conditions => [
          "internal = ? AND (country_code LIKE ? OR country_code IS NULL)",
          true,
          "#{I18n.locale_country(locale_cache_key) || "US"}"
        ]
      ).reject {|p| !p.active?}.first].reject {|k,v| v == nil})
      return @promotable_product_cache[locale_cache_key]
    end
    nil
  end

  def redeem!
    raise "Implement in subclass"
  end
  
  # returns the voucher code in dasherized format, e.g. qzba-trve-nuxy
  def code
    dasherized_code
  end

  # assembles :code_1s, :code_2s, :code_3s to a full :code_confirmation_attribute
  def code_confirmation_attributes=(some_attributes={})
    voucher_code = []
    (1..3).each do |index|
      voucher_code << some_attributes["#{index}s"]
    end
    self.code_confirmation = voucher_code.join('-') unless voucher_code.join.empty?
  end
  
  def code_confirmation(index=nil)
    return @code_confirmation unless index
    if @code_confirmation
      if case index
          when 1 then /^([a-z,0-9]{0,4})-/i.match(@code_confirmation)
          when 2 then /^[a-z,0-9]{0,4}-([a-z,0-9]{0,4})/i.match(@code_confirmation)
          when 3 then /^[a-z,0-9]{0,4}-[a-z,0-9]{0,4}-([a-z,0-9]{0,4})/i.match(@code_confirmation)
        end
        return $1
      end
    end
  end
  
  # returns the voucher code
  def to_s
    self.code
  end
  
  # returns the voucher code in dasherized format but obfuscated, e.g. trve-nuxy-****
  def obfuscated_code
    self.class.dasherize_code(self.class.obfuscate_code(self[:code])) if self[:code]
  end
  
  def undasherized_code
    self.class.undasherize_code(self[:code]) if self[:code]
  end

  def dasherized_code
    self.class.dasherize_code(self[:code]) if self[:code]
  end
  
  # Reader symbolizes type / kind
  def kind
    self.class.kind
  end
  
  # Writer symbolizes type / kind
  def kind=(type)
    # dummy setter for compatibilty reasons
  end

  # Reader symbolizes uuid_base
  def uuid_base
    read_attribute(:uuid_base).to_sym unless read_attribute(:uuid_base).nil?
  end

  # Writer symbolizes uuid_base
  def uuid_base=(a_base)
    write_attribute(:uuid_base, a_base.to_s)
  end
  
  # for cart line item when price is copied
  # make sure we copy the name in the right language
  def copy_name(options={})
    if self.consignee
      I18n.switch_locale self.consignee.default_language do
        self.class.human_name
      end
    else
      self.class.human_name
    end
  end

  # for cart line item when price is copied
  def copy_price(options={})
    if pp = self.promotable_product(options[:locale])
      if self.consignee
        # determine the price of the promotable
        promotable_line_item = consignee.cart.cart_line_item(pp)
        self.price = promotable_line_item.price.abs * -1
        return self.price
      end
    end
    Money.new(0, self.consignee ? self.consignee.default_currency : 'USD')
  end
  
  # when added to order it will determine if taxes will apply to this voucher
  def taxable?
    @taxable_product_cache || @taxable_product_cache = if self.promotable
      self.promotable
    elsif self.promotable_sku
      Product.find_like_by_sku(self.promotable_sku).first
    else
      false
    end
    if @taxable_product_cache
      if @taxable_product_cache.respond_to?(:taxable?)
        return @taxable_product_cache.send(:taxable?)
      elsif @taxable_product_cache.respond_to?(:taxable)
        return @taxable_product_cache.send(:taxable)
      end
    end
    false
  end
  
  # for cart line item when price is copied
  def copy_item_number(options={})
    "VO#{self.id}"
  end
  
  # for cart line item when price is copied
  def copy_description(options={})
    if self.consignee
      I18n.switch_locale self.consignee.default_language do
        "%{type} from %{consignor} for %{description} (%{obfuscated_code})".t % {
          :type => self.class.human_name,
          :obfuscated_code => self.obfuscated_code,
          :consignor => self.consignor ? self.consignor.name : SERVICE_NAME,
          :description => self.promotable_t.titleize
        }
      end
    else
      "%{type} from %{consignor} for %{description} (%{obfuscated_code})".t % {
        :type => self.class.human_name,
        :obfuscated_code => self.obfuscated_code,
        :consignor => self.consignor ? self.consignor.name : SERVICE_NAME,
        :description => self.promotable_t.titleize
      }
    end
  end
  
  # returns true if there is no consignor so this voucher is anonymous
  def anonymous?
    !self.consignee
  end

  # returns true if voucher has a consignee, opposite of anonymous?
  def consignee?
    !!self.consignee
  end

  # assigns a consignee and saves the record
  def consignee_and_save=(a_consignee)
    self.consignee = a_consignee
    self.save(false)
  end

  def validate
    self.errors.add(:code, I18n.t('activerecord.errors.messages.expired')) if self.expired?
    self.errors.add(:code, I18n.t('activerecord.errors.messages.redeemed')) if self.redeemed?
    if self.consignee && self.consignee_confirmation && self.consignee_confirmation != self.consignee
      self.errors.add(:consignee_confirmation, I18n.t('activerecord.errors.messages.invalid'))
    end
    
    if self.validate_code_confirmation?
      if Voucher.undasherize_code(self.code.to_s) != Voucher.undasherize_code(self.code_confirmation.to_s)
        self.errors.add(:code_confirmation, I18n.t('activerecord.errors.messages.unknown_voucher'))
      end
    end
  end

  # returns true if the (promotion) code should be validated on validate,
  # by default this returns false as the developers intends to create a new
  # promotion code on Voucher.new.
  #
  # exception, controller code, when code is entered and needs to be validated
  #
  def validate_code_confirmation?
    !!@validate_code_confirmation
  end

  # returns true if the validation code (captcha) should be validated,
  # normally, this should return false
  def validate_verification_code?
    @validate_verification_code == true
  end

  protected 
  
  # called by redeem! to setup negative price and taxability
  def setup_properties_from_promotable_for_redemption(a_promotable=self.promotable)
    if a_promotable
      self.taxable = if a_promotable.respond_to?(:taxable?)
        a_promotable.send(:taxable?)
      elsif a_promotable.respond_to?(:taxable)
        a_promotable.send(:taxable)
      else
        false
      end
    
      if self.consignee
        # determine the price of the promotable
        promotable_line_item = consignee.cart.cart_line_item(a_promotable)
        self.price = -promotable_line_item.price
        return true if (self.price + promotable_line_item.price).zero?
      end
    end
    false
  end

  # dummy for active scaffolds
  class Promotable < ActiveRecord::Base
  end
  
end
