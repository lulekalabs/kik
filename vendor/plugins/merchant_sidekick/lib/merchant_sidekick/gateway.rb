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
# Base class for all gatway implementations. The premise is that the gatway
# class accessor Gatway.gateway can either be configured from an environment file
# or if not, it can be defined inside the DB table using the Name column.
# The name column will infer the configuration file which must reside inside
# the rails config/ folder is named after the gateway name, such as
# config/authorize_net.yml
#
class Gateway < ActiveRecord::Base
  #--- accessors
  cattr_accessor :gateway          # ->  caches gateway instance in decendants, e.g. in PaypalGateway.gateway
  cattr_accessor :default_gateway  # ->  sets default gateway as instance or class (symbol) optional

  #--- associations
  
  #--- class methods
  
  class << self 
  
    def config_file_name
      "bogus_gateway.yml"
    end

    def config(file_name=nil)
      { :mode => 'test' }
    end

    def default_gateway
      @@default_gateway || raise("No gateway defined in #{ENV['RAILS_ENV']} environment, e.g. MerchantSidekick::Gateway.default_gateway = :authorize_net_gateway")
    end
    
    # Note: deprecate
    def gateway
      puts "DEPRECATED: use default_gateway"
      default_gateway
    end
    
    # Note: deprecate=
    def gateway=(a_gateway)
      puts "DEPRECATED: use default_gateway="
      default_gateway=(a_gateway)
    end
    
  end
  
  #--- instance methods
  
  # symbolizes name column string such as
  # e.g. 'authorize_net', 'Authorize Net', 'authorize.net' all to :authorize_net
  def service_name
    self[:name].gsub(/\.|,/, '_').gsub(/\s/, '').underscore.to_sym if self[:name]
  end
  
  def config_file_name
    "#{self.service_name}.yml"
  end

  # returns the gateway instance specified by name stored in the DB, where:
  #
  #   DB NAME column         Class Name              Config File Name        Service Name
  #   'authorize_net'        AuthorizeNetGateway     authorize_net.yml       :authorize_net
  #   'Authorize.net'        dito                    ...                     ...
  #
  def gateway
    begin
      "#{self.service_name}Gateway".classify.gateway(self.config_file_name)
    rescue
      self.class.gateway(self.config_file_name)
    end
  end
    
end