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
# Implements the authorize.net specific gateway configuration
class AuthorizeNetGateway < Gateway
  #--- accessors
  cattr_accessor :authorize_net_login_id
  cattr_accessor :authorize_net_transaction_key

  #--- class methods
  class << self 
    
    def config_file_name
      "authorize_net.yml"
    end

    # returns a configuration context read from a yml file in /config
    def config(file_name=nil)
      # Authorize.net configuration
      result = YAML.load_file(RAILS_ROOT + "/config/#{file_name || config_file_name}")[RAILS_ENV].symbolize_keys
      @@authorize_net_login_id = result[:login_id]
      @@authorize_net_transaction_key = result[:transaction_key]
      if result[:mode] == 'test'
        # Tell ActiveMerchant to use the Authorize.net sandbox
        ActiveMerchant::Billing::Base.mode = :test
      end
      result
    end
  
    # returns a gateway instance unless there is one assigned globally from the
    # environment files
    def gateway(file_name=nil)
      unless @@gateway
        authorize_net_config = config(file_name)
        @@gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new({
          :login  => authorize_net_config[:login_id],
          :password => authorize_net_config[:transaction_key]
        }.merge(authorize_net_config[:mode] == 'test' ? { :test => true } : {}))
      end
      @@gateway
    end
  
  end

end