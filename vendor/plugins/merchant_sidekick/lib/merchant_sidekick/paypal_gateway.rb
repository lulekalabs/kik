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
# Implements the Paypal Website Payments Pro specific gateway configuration
# 
# development:
#   api_username: seller_xyz_biz_api1.example.com
#   api_password: DMLxxx
#   pem_file_name: dev_cert.txt
#   signature: Aiadlsfsdfdlsfjklsdjf;lasdjfkljsdf;ljlk
#   mode: test
#  ...
#
class PaypalGateway < Gateway
  #--- accessors
  cattr_accessor :paypal_api_username
  cattr_accessor :paypal_api_password
  cattr_accessor :paypal_signature
  cattr_accessor :paypal_pem_file_name

  #--- class methods
  class << self 
    
    def config_file_name
      "paypal.yml"
    end

    # returns a configuration context read from a yml file in /config
    def config(file_name=nil)
      # Authorize.net configuration
      result = YAML.load_file(RAILS_ROOT + "/config/#{file_name || config_file_name}")[RAILS_ENV].symbolize_keys
      @@paypal_api_username  = result[:api_username]
      @@paypal_api_password  = result[:api_password]
      @@paypal_signature     = result[:signature] unless result[:signature].blank?
      @@paypal_pem_file_name = RAILS_ROOT + "/config/#{result[:pem_file_name]}" unless result[:pem_file_name].blank?
      ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(@@paypal_pem_file_name) if @@paypal_pem_file_name
      # Tell ActiveMerchant to use the Authorize.net sandbox
      ActiveMerchant::Billing::Base.mode = :test if result[:mode] =~ /test/i
      result
    end
  
    # returns a gateway instance unless there is one assigned globally in the
    # environment files 
    #
    # e.g.
    # 
    #  config.after_initialize do 
    #    ...  
    #    CreditCardPayment.gateway = ActiveMerchant::Billing::BogusGateway.new
    #    ...
    #  end
    #
    def gateway(file_name=nil)
      unless @@gateway
        yml_config = config(file_name)
        
        options = {}
        options.merge!({
          :login  => yml_config[:api_username],
          :password => yml_config[:api_password]}
        )
        options.merge!({:test => true}) if yml_config[:mode] =~ /test/i
        options.merge!({:signature => yml_config[:signature]}) unless yml_config[:signature].blank?
        @@gateway = ActiveMerchant::Billing::PaypalGateway.new(options)
      end
      @@gateway
    end
  
  end

end