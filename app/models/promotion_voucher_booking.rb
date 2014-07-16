class PromotionVoucherBooking < Tableless

  #--- columns
  column :amount
  column :number
  column :expires_at
  column :multiple_redeemable
  
  #--- validations
  validates_presence_of :amount, :number, :expires_at
  #validates_numericality_of :amount, :only_integer => true
  validates_inclusion_of :amount, :in => 1..100
  validates_inclusion_of :number, :in => 1..1000
    
  #--- instance methods

  def initialize(attributes={})
    date_hack(attributes, "expires_at")
    super(attributes)
  end

  def date_hack(attributes, property)
    keys, values = [], []
    keys = attributes.stringify_keys.keys.select {|k| k.to_s =~ /#{property}/}.sort.map(&:to_sym)
    keys.each { |k| values << attributes[k]; attributes.delete(k); }
    
    if !values.empty? && (time = Time.parse(values.join("-")))
      attributes[property] = time
    else
      attributes[property] = Time.now.utc + 1.month
    end
  end
    
  def create!
    if self.valid?
      PromotionContactVoucher.generate(self.number, :amount => self.amount, :expires_at => self.expires_at,
        :multiple_redeemable => self.multiple_redeemable)
      return true
    end
    false
  end
  alias_method :create, :create!
  
  def amount
    self[:amount].to_i
  end

  def number
    self[:number].to_i
  end

  def multiple_redeemable
    self[:multiple_redeemable] ? !!(self[:multiple_redeemable].to_s =~ /^(1|true)$/) : false
  end
  
  protected
  
  def validate
    self.errors.add(:expires_at, "muss in der Zunkunf liegen") if self.expires_at.today? || self.expires_at < Time.now.utc
  end
  
end