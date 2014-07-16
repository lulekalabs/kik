# The redeemer will receive some free contacts upon redemption
class PromotionContactVoucher < Voucher
  
  #--- class methods
  class << self
    
    def generate(quantity, options={})
      super(quantity, options.reverse_merge({:amount => 100, :type => :promotion_contact_voucher}))
    end

    def kind
      :promotion_contact_voucher
    end

  end
  
  #--- instance methods
  
  # redeems this voucher
  # in case the voucher contains a promotable (product), it currently
  # all of the following criteria must be true:
  #
  #  * if voucher is valid
  #  * if there is a consignee (not anonymous)
  #
  # then book the contacts
  #
  def redeem!(with_order=false)
    return false unless self.valid?
    return false if self.anonymous?
    result = false
    
    transaction = self.consignee.promotion_contact_transactions.create(
      :amount => self.amount, :expires_at => Time.now.utc + 1.month)
      
    if transaction.valid?
      if self.multiple_redeemable
        self.voucher_redemptions.create(:voucher => self, :person => self.consignee, :redeemed_at => Time.now.utc)
        self.redeemed_at = nil
        self.consignee = nil
      else
        self.redeemed_at = Time.now.utc
      end
      result = self.save(false)
    end
    result
  end
  
  # in addition to standard voucher validations, we want to make sure that
  # the consignee has not been using any promotion contact vouchers within the last day
  def validate
    super
    consignee_to_test = self.consignee || self.consignee_confirmation
    if consignee_to_test && consignee_to_test.is_a?(Advocate)
      if consignee_to_test.promotion_contact_transactions.find(:first,
          :conditions => ["contact_transactions.created_at < ?", Time.now.utc - 1.day])
        self.errors.add(:code, I18n.t('activerecord.errors.messages.invalid'))
      end
    end

  end
  
end