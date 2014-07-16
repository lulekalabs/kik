#
# Copyright (c) 2007-2011 Juergen Fesslmeier
# 
# Permission is hereby granted, to kann-ich-klagen.de, for this software and associated 
# documentation files (the "Software"). The Software is restricted, including the rights 
# to copy, modify, merge, publish, distribute, sublicense, and/or sell or resell copies
# of the Software, and is not permitted to persons to whom the Software is not furnished 
# to do so.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# This class handles all credit card payment transactions
class CreditCardPayment < Payment
  #--- accessors
  cattr_accessor :gateway
  serialize :params

  #--- class methods
  class << self

    # returns active merchant gateway, based on 
    #
    #   * an active merchant gateway was assigned to gateway class accessor
    #   * a gateway implementation identifier, like :authorize_net_gateway was passed 
    #     into the gateway class accessor
    #
    # override or define this as needed in environment like:
    #
    #   CreditCardPayment.gateway = :authorize_net_gateway
    #
    def gateway
      if @@gateway
        # return ActiveMerchant gateway instance
        return @@gateway if @@gateway.is_a? ActiveMerchant::Billing::Gateway
        # or get the ActiveMerchant gateway instance through Merchant Sidekick's gateway
        # e.g. :authorize_net_gateway -> AuthorizeNetGateway.gateway
        @@gateway = @@gateway.to_s.classify.constantize.gateway
      else
        @@gateway = Gateway.default_gateway
      end
    end
    
    def authorize(amount, credit_card, options = {})
      process('authorization', amount) do |gw|
        gw.authorize(amount, credit_card, options)
      end
    end
    
    def capture(amount, authorization, options = {})
      process('capture', amount) do |gw|
        gw.capture(amount, authorization, options)
      end
    end
    
    def purchase(amount, credit_card, options = {})
      process('purchase', amount) do |gw|
        gw.purchase(amount, credit_card, options)
      end
    end

    def void(amount, authorization, options = {})
      process('void', amount) do |gw|
        gw.void(authorization, options)
      end
    end

    # requires :card_number option
    def credit(amount, authorization, options = {})
      process('credit', amount) do |gw|
        gw.credit(amount, authorization, options)
      end
    end
    
    # works with paypal payflow
    def transfer(amount, destination_account, options={})
      process('transfer', amount) do |gw|
        gw.transfer(amount, destination_account, options)
      end
    end

    private
    
    def process(action, amount = nil)
      result = CreditCardPayment.new
      result.amount = amount
      result.action = action
    
      begin
        response = yield gateway
    
        result.success   = response.success?
        result.reference = response.authorization
        result.message   = response.message
        result.params    = response.params
        result.test      = response.test?
      rescue ActiveMerchant::ActiveMerchantError => e
        result.success   = false
        result.reference = nil
        result.message   = e.message
        result.params    = {}
        result.test      = gateway.test?
      end
      result
    end
  end
  
  #--- instance methods
  
  # override in sublcass
  def payment_type
    :credit_card
  end
  
end