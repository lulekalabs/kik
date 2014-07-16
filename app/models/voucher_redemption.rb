# Redeemer of a voucher
class VoucherRedemption < ActiveRecord::Base
  
  #--- assocations
  belongs_to :person
  belongs_to :voucher
  
end
