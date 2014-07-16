# Manages the list of available products
class Product < ActiveRecord::Base

  cattr_accessor :monthly_term_days
  @@monthly_term_days = 30
  cattr_accessor :anual_term_days
  @@anual_term_days = 365

  #--- scopes
  named_scope :active, :conditions => ["products.active = ?", true]

  #--- mixins
  money :price, :cents => :cents, :currency => :currency
  acts_as_list
  
  #--- validations
  validates_presence_of :name, :sku
  validates_uniqueness_of :sku
  
  #--- instance methods

  # indicates to merchant_sidekick that all products can be taxed
  def taxable?
    true
  end
  
  # yes if contacts are part of this
  def has_contacts?
    self[:contacts].to_i > 0
  end
  
  # inverse of ditto
  def has_no_contacts?
    !self.has_contacts?
  end
  
  # true if "flat paket"
  def has_unlimited_contacts?
    self[:flat] || false
  end
  alias_method :flat?, :has_unlimited_contacts?
  alias_method :is_flat?, :has_unlimited_contacts?
  
  # true if subscribable
  def is_subscription?
    self[:subscription] || false
  end

  # flex package yes
  def is_flex?
    self.sku == "P001"
  end
  alias_method :flex?, :is_flex?

  # contacts
  def is_contact?
    self.sku == "K001"
  end

  # is paper bill
  def is_paper_bill?
    self.sku == "X001"
  end
  
  # similar products, e.g. 20er monthly is family of 20er anually, flex is not similar to anything
  def is_similar_to?(product)
    if product
      if self.is_subscription? && product.is_subscription?
        if self.contacts == product.contacts
          return true
        end
      end
    end
    false
  end

  # is not within the same product family
  def is_different_to?(product)
    !self.is_similar_to?(product)
  end
  
  # e.g. "40 contacts are superior to 20", "flex is superior to no product" 
  def is_superior_to?(product)
    if product && product.is_subscription? && self.is_subscription?
      if self.is_flat? && product.is_flat?
        return false
      elsif self.is_flat? && !product.is_flat?
        return true
      elsif self.contacts.to_i != 0 && product.is_flat?
        return false
      elsif self.contacts.to_i > product.contacts.to_i
        return true
      end
    elsif self.is_subscription? && product.nil?
      return true
    end
    false
  end

  # inverse of dito
  def is_inferior_to?(product)
    !self.is_superior_to?(product)
  end
  
  # returns the number of days the customer is bound to this product as in "mindestlaufzeit"
  def term_in_days
    if self.is_subscription?
      if RAILS_ENV == "production" && self.attributes.symbolize_keys.keys.include?(:term_in_days)
        self[:term_in_days] || self.monthly_term_days
      else
        # determine by configured sku codes
        if self.sku.match(/^S([0-9]*)$/i)
          self.anual_term_days
        elsif self.sku.match(/^P([0-9]*)$/i)
          self.monthly_term_days
        end
      end
    end
  end
  
  # dummy helper for VAT
  def tax_rate
    self[:tax_rate] || 19.0
  end
  
  protected
  
  # added this to workaround the serialization bug with cart, where
  # cart.line_items.product would throw an exception, where target
  # was not found in Product. The error occured in 
  # /opt/local/lib/ruby/gems/1.8/gems/activerecord-2.0.2/lib/active_record/associations.rb
  #
  # TODO: investigate whether this is necessary, for now leave this in here, please!
  def target
    ""
  end

  # added as a workaround when inventory tries to save cart_line_items and line_items
  # TODO figure out how to fix this otherwise, its coming from active_scaffold
  def updated?
    false
  end
  
  def price_is_net?
    true
  end
  
end
