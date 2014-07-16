# e.g. Rechtsanwalt
class Advocate < Person
  
  attr_accessor :desired_product_sku
  attr_reader :concession # dummy for scaffold
  attr_accessor :terms_of_service # dummy for scaffold
  attr_accessor :activated_at # dummy for scaffold
  @@active_advocates_count = nil
  
  #--- assocations
  belongs_to :bar_association
  belongs_to :primary_expertise, :class_name => "Topic", :foreign_key => :primary_expertise_id
  belongs_to :secondary_expertise, :class_name => "Topic", :foreign_key => :secondary_expertise_id
  belongs_to :tertiary_expertise, :class_name => "Topic", :foreign_key => :tertiary_expertise_id
  has_and_belongs_to_many :topics, :join_table => "advocates_topics", :foreign_key => :advocate_id
  
  has_many :accesses, :foreign_key => :requestor_id, :dependent => :destroy
  has_many :accessible_kases, :through => :accesses, :source => :accessible
  has_many :premium_contact_transactions, :foreign_key => :person_id, :dependent => :destroy
  has_many :promotion_contact_transactions, :foreign_key => :person_id, :dependent => :destroy
  has_many :overdrawn_contact_transactions, :foreign_key => :person_id, :dependent => :destroy
  has_many :responses, :foreign_key => :person_id, :dependent => :destroy
  has_many :reviews, :foreign_key => :reviewee_id, :dependent => :destroy
  has_many :advomessages, :foreign_key => :sender_id, :dependent => :destroy
  has_many :articles, :foreign_key => :person_id, :dependent => :destroy
  has_many :company_assets, :as => :assetable, :dependent => :destroy
  has_many :mandates, :foreign_key => :advocate_id, :dependent => :destroy
  has_many :given_mandates, :foreign_key => :advocate_id, :dependent => :destroy, :class_name => "ClientMandate"
  has_many :received_mandates, :foreign_key => :advocate_id, :dependent => :destroy, :class_name => "AdvocateMandate"

  acts_as_visitable
  acts_as_buyer
  acts_as_mappable :default_units => :kms, 
    :default_formula => :flat, :distance_field_name => :distance
  
  #--- scopes
  named_scope :reviewed_by, lambda {|reviewer| {:conditions => ["reviews.status IN (?)", ['open']],
    :joins => "LEFT OUTER JOIN reviews ON reviews.reviewer_id = #{reviewer.id} AND reviews.reviewee_id = people.id"}}
  named_scope :unreviewed_by, lambda {|reviewer| {:conditions => "accesses.requestor_id = people.id AND (SELECT COUNT(reviews.id) FROM reviews WHERE reviews.reviewee_id = accesses.requestor_id AND reviews.reviewer_id = #{reviewer.id}) = 0",
    :joins => "LEFT OUTER JOIN accesses ON accesses.requestee_id = #{reviewer.id} AND accesses.requestor_id = people.id"}}
  
  #--- validations
  validates_associated :business_address
  validates_associated :company_assets
  validates_presence_of :bar_association_id
  validates_presence_of :gender, :first_name, :last_name, :phone_number
  validates_format_of :tax_number, :allow_blank => true, :with => /^DE[0-9]{9}/i
  validates_presence_of :bank_account_owner_name, :bank_account_number, :bank_routing_number, :bank_name, :bank_location,
    :if => Proc.new {|o| o.preferred_payment_method == "debit"}
  validates_presence_of :paypal_account,
    :if => Proc.new {|o| o.preferred_payment_method == "paypal"}
  validates_email_format_of :paypal_account, :if => Proc.new {|o| o.preferred_payment_method == "paypal"}
  
  #--- callbacks
  before_validation :reject_blank_assets

  #--- class methods
  class << self
    
    def enrollment_class
      AdvocateEnrollment
    end
    
    def active_count
      @@active_advocates_count || @@active_advocates_count = count({:conditions => ["users.state = ? AND people.type = ?", 'active', 'Advocate'], :include => :user})
    end
    
  end

  #--- instance methods
  
  def to_s
    "Newsletter für Anwälte"
  end

  # Inklusivkontakte
  def premium_contacts_count
    self[:premium_contacts_count]
  end
  
  # Freikontakte
  def promotion_contacts_count
    self[:promotion_contacts_count]
  end

  # überhangs/überzugs-kontakte
  def overdrawn_contacts_count
    self[:overdrawn_contacts_count]
  end
  
  def total_contacts_count
    self.premium_contacts_count + self.promotion_contacts_count
  end
  
  # did the advocate purchase a flat contacts product?
  def unlimited_premium_contacts?
    self.premium_contact_transactions.active.each do |ct|
      return true if ct.flat?
    end
    false
  end

  # can the advocate purchase additional contacts during a service period
  def can_purchase_flex_contacts?
    !self.premium_contact_transactions.active.empty?
  end
  
  def update_contacts_count
    # due to test failure changing from scopes to conditions
    premium_contact_sum = self.premium_contact_transactions.sum(:amount, :conditions => ["(contact_transactions.expires_at >= ? AND contact_transactions.start_at IS NULL) OR (contact_transactions.start_at <= ? AND contact_transactions.expires_at >= ?)", Time.now.utc, Time.now.utc, Time.now.utc])
    promotion_contact_sum = self.promotion_contact_transactions.sum(:amount, :conditions => ["(contact_transactions.expires_at >= ? AND contact_transactions.start_at IS NULL) OR (contact_transactions.start_at <= ? AND contact_transactions.expires_at >= ?)", Time.now.utc, Time.now.utc, Time.now.utc])
    self.update_attributes(:premium_contacts_count => premium_contact_sum,
      :promotion_contacts_count => promotion_contact_sum)
    #self.update_attributes(:premium_contacts_count => self.premium_contact_transactions.active.sum(:amount),
    #  :promotion_contacts_count => self.promotion_contact_transactions.active.sum(:amount))
  end
  
  def access_by?(person)
    !!accessible_kases.find(:first, :conditions => ["accesses.requestee_id = ?", person.id])
  end

  def access_to?(kase)
    !!accessible_kases.find(:first, :conditions => ["accesses.accessible_id = ?", kase.id])
  end

  # if we have access to given question, return the kase "owner" person
  def requestee_of(kase)
    if kase = accessible_kases.find(:first, :conditions => ["accesses.accessible_id = ?", kase.id])
      kase.person
    end
  end

  # handles the process of "contacting" a client's question. in the process 
  # wee need to make sure that the advocate has enough acquired contacts.
  def access_to!(kase)
    access = false
    unless self.access_to?(kase)
      access = Access.new(:requestor => self, :requestee => kase.person, :accessible => kase)
      if access.valid?
        accesses << access
        accesses.reload
        return !access.new_record?
      end
    end
    access
  end

  # has the advocate contacted this question's client before? 
  # has the advocate suffcicient allocated contacts on his account?
  def can_access?(kase)
    ca = self.access_to?(kase)
    ca || (!ca && (self.total_contacts_count > 0 || self.can_purchase_flex_contacts? || self.unlimited_premium_contacts?))
  end
  
  # returns true if a contact could be "deducted" from the account
  def decrement_contact
    result = false
    if self.unlimited_premium_contacts?
      result = true
    elsif self.total_contacts_count > 0
      if self.premium_contacts_count > 0
        if ct = self.premium_contact_transactions.active.positive.reverse.first
          ct.decrement!(:amount, 1)
          result = true
        end
      elsif self.promotion_contacts_count > 0
        if ct = self.promotion_contact_transactions.active.positive.reverse.first
          ct.decrement!(:amount, 1)
          result = true
        end
      end
    elsif self.can_purchase_flex_contacts?
      pct = self.premium_contact_transactions.active.find(:all, :order => "contact_transactions.id").last
      if pct 
        if ooi = pct.order || pct.invoice
          self.overdrawn_contact_transactions.create(
            :amount => 1, :expires_at => ooi.service_period_end_on.to_time)
          result = true
        end
      end
    end
    result
  end
  
  # has this person responded to question
  def responded_to?(kase)
    !!self.responses.find(:first, :conditions => ["responses.kase_id = ?", kase.id])
  end

  # returns the advocate's response to the given kase
  def response_to(kase)
    self.responses.find(:first, :conditions => ["responses.kase_id = ?", kase.id])
  end

  # prints either user.login, user.person.name or user.id
  def user_id
    self.title_and_name
  end
  
  # alias for visits_count
  def page_views_count
    self.visits_count
  end
  
  # remove rounding errors
  def grade_point_average
    if self[:grade_point_average]
      (self[:grade_point_average] * 100).to_i / 100.to_f
    end
  end
  alias_method :gpa, :grade_point_average
  
  # assigns nested attributes
  def company_assets_attributes=(options)
    options.each do |k,v|
      v.symbolize_keys!
      if v[:id].nil?
        # new
        self.company_assets.build({:person => self}.merge(v))
      elsif v[:id] != 0 && v[:_delete] =~ /^(1|true)/i
        # delete
        if asset = self.company_assets.to_a.find {|r| r.id == v[:id].to_i}
          self.company_assets.delete(asset)
        end
      end
    end
  end
  
  # creates clear text of preferred_payment_method
  def preferred_payment_method_name
    case self.preferred_payment_method.to_s
    when /debit/ then "Zahlung per Lastschrift"
    when /invoice/ then "Zahlung per Rechnung"
    when /paypal/ then "Zahlung per Paypal"
    end
  end

  def preferred_billing_method_name
    case self.preferred_billing_method.to_s
    when /pdf_and_paper/ then "Versand per E-Mail als PDF + per Post in Papierform"
    when /pdf/ then "Versand per E-Mail als PDF (kostenlos)"
    end
  end
  
  # copy from business address if no billing address is defined
  def default_billing_address(options={})
    unless self.billing_address
      self.build_billing_address(options.merge({
        :company_name => self.company_name, :academic_title_id => self.academic_title_id, :gender => self.gender,
          :first_name => self.first_name, :last_name => self.last_name,
            :street => self.business_address.street, :street_number => self.business_address.street_number,
              :note => self.business_address.note, :postal_code => self.business_address.postal_code,
                :city => self.business_address.city, :country_code => self.business_address.country_code,
                  :email => self.email}))
    else
      self.billing_address
    end
  end

  # returns the transaction that is still active
  def last_active_premium_contact_transaction
    return @last_active_premium_contact_transaction_cache if @last_active_premium_contact_transaction_cache
    result = nil
    premium_contact_transactions.active.reverse.each do |ct|
      product = ct.active_product
      result = ct if product
      break if result
    end
    @last_active_premium_contact_transaction_cache = result
  end
  
  #  returns the active purchased product e.g. "Flex Paket"
  def last_active_product
    if ct = self.last_active_premium_contact_transaction
      ct.active_product
    end
  end
  alias_method :current_product_subscription, :last_active_product

  #  returns the active purchased product e.g. "40er Paket Abonnement"
  def last_active_product_subscription
    if ct = self.last_active_premium_contact_transaction
      return ct.active_product if ct.active_product.subscription?
    end
  end

  # when does the last active product subscription expire?
  def last_active_product_subscription_expires_at
    if ct = self.last_active_premium_contact_transaction
      return ct.expires_at if ct.active_product.subscription?
    end
  end

  # returns last purchase order of this service period
  def last_active_recurring_order
    self.orders.recurring.find(:all, :order => "orders.id ASC").select {|o| Date.today >= o.service_period_start_on && Date.today <= o.service_period_end_on}.last
  end
  
  # returns product subscription that's still active and recurring
  def last_active_recurring_product_subscription
    if order = self.last_active_recurring_order
      order.line_item_products.select(&:subscription?).first
    end
  end

  # when does the term period start, e.g. on a S020 product ordered today
  # the term starts today
  def last_active_recurring_product_subscription_term_period_start_on
    if order = self.last_active_recurring_order
      order.created_at.to_date
    end
  end

  # when does the term period end, e.g. on a S020 product ordered today
  # the term ends in 365 days from today
  def last_active_recurring_product_subscription_term_period_end_on
    if order = self.last_active_recurring_order
      order.created_at.to_date + last_active_recurring_product_subscription.term_in_days
    end
  end

  # determines the start date of a product subscription. If a product has already been
  # subscribed, it must be determined when the current product term ends, the new start
  # date would be one day after the current term ends. If no product has been subscribed
  # date is today.
  def new_recurring_product_subscription_start_on
    # if currrent_end_date = self.last_active_recurring_product_subscription_term_period_end_on
    if current_order = last_active_recurring_order
      current_order.service_period_end_on + 1.day
    else
      Date.today
    end
  end

  # date when the current subscription can be canceled, this is currently set 3 days before the term ends
  def last_active_recurring_product_subscription_term_cancel_on
    if end_date = self.last_active_recurring_product_subscription_term_period_end_on
      end_date - 3.days
    end
  end

  # can this product subscription be canceled? only 3 days starting before term end until term ends
  def can_cancel_current_product_subscription?
    if (cancel_date = self.last_active_recurring_product_subscription_term_cancel_on) &&
        (term_end_date = self.last_active_recurring_product_subscription_term_period_end_on)
      if cancel_date <= Date.today && Date.today <= term_end_date 
        return true
      end
    end
    false
  end
  
  # is there abd order for a next period
  def next_recurring_order
    if actual_order = self.last_active_recurring_order
      self.orders.recurring.find(:all, :conditions => ["orders.id > ?", actual_order.id],
        :order => "orders.id ASC").first
    end
  end
  
  def next_recurring_product_subscription
    if order = self.next_recurring_order
      order.line_item_products.select(&:subscription?).first
    end
  end
  alias_method :next_product_subscription, :next_recurring_product_subscription
  
  # has any expertise assigned
  def has_expertise?
    self.primary_expertise || self.secondary_expertise || self.tertiary_expertise
  end

  # needs to change to topics
  def has_topics?
    !self.topics.empty?
  end

  protected
  
  def validate
    super
    if self.desired_product_sku
      desired_product = Product.find_by_sku(self.desired_product_sku)
      active_product = self.last_active_product_subscription
      unless desired_product.is_different_to?(active_product) && (desired_product.is_superior_to?(active_product) || self.can_cancel_product_subscription?)
        term_end_on = last_active_recurring_product_subscription_term_period_end_on
        self.errors.add :desired_product_sku, "Wechsel erst am Ende der Mindestlaufzeit zum #{I18n.l(term_end_on, :format => "%d.%m.%Y")} möglich"
      end
    end
  end
  
  def update_grade_point_average
    self.class.transaction do
      self.lock!
      self.update_attribute(:grade_point_average, self.reviews.visible.average(:grade_point_average))
    end
  end

  # remove all empty assets
  def reject_blank_assets
    #self.company_assets.each {|a| self.company_assets.delete(a) if a.file.url.to_s =~ /missing.png/ || a.file.blank?}
  end
  
end
