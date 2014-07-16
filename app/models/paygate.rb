#
# Copyright (c) 2011 Juergen Fesslmeier
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
#
# Paygate Interface
#
# Der string muß folgende Parameter enthalten:
#
#  MerchantID=mschweizer&AccBank=bank&Amount=200&AccNr=123456&AccOwner=owner&AccIBAN=44448888&OrderDesc=test&TransID=1216126620656&Currency=EUR
#
# Dann wird der string blowfish verschlüsselt und an folgende Adresse
# gesandt:
#
# https://www.netkauf.de/paygate/edddirect.aspx
#
# So sieht das dann aus:
#
# https://www.netkauf.de/paygate/edddirect.aspx?&MerchantID=mschweizer&L
# en=140&Data=ECD4E85467B7DD2049C33A9C7AD619702929381925382A3727882D5C21C220401CDCCC16858DA8385F609497A022E4146BA6F288AEDFE261A9F5FB3BFCF14EE724E06384756D0FD7682936628A3BDDF20FD3B217B926584E239DF760DD784B020311A849395C77FFB51A5EC9D78B9D390B 603887AD2C3C6E0955CCCE8737292C27C54E162AAB9DA34A1C71B300E3FBFC
#
# unser response verschlüsselt:
#
# Len=160&Data=2188B3CA279CF1E8A06C239786E7101FBB9D8AACEACA29C64B7DAB0779DBA019EDB1DA86AC861D6A4458FE4586CEF6DA048DEDB2026E64FB9B2C61E97CA23B2D109BA4F009D872BB89D3FFDC750F4CA95BE4398525C8A0962E6BBCE6977E649A66514BEC814356F5D27C578C09BEE377A440B692D2326B5C4F5C84657089BF8B60BD5B2F771CDDA8A8623E2224D3F38178D88FB03395C3045CA701CA1B091D03
#
# Response entschlüsselt:
#
# PayID=266d7ec17e554ec68c9439792aa9f2d3&XID=7c1f5079abe64ca3ad18b81920a2767d&TransID=1216126620656&mid=mschweizer&Status=FAILED&Code=21110500&Description=INVALID
#
#
# Furhter references:
#
#  http://www.ruby-doc.org/core-1.9/classes/OpenSSL/SSL/SSLContext.html
#  http://www.ruby-doc.org/stdlib-1.8.7/libdoc/openssl/rdoc/classes/OpenSSL/SSL/SSLSocket.html
#
class Paygate
  require 'crypt/blowfish'
  require 'net/http'
  require 'net/https'
  require 'openssl'
  require 'socket'
  
  cattr_accessor :test
  @@test = false
  
  #--- class attributes
  cattr_accessor :merchant_id
  @@merchant_id = "mschweizer"
  cattr_accessor :password
  @@password = "b!3X)Zk9c2N]Co[5"
  # @@password = "test"

  class << self

    def test?
      @@test
    end

    # Lastschriften über Socket-Verbindungen (2.4.7)
    # https://www.netkauf.de/paygate/edddirect.aspx
    def debit(amount, bank_account, options={})
      transaction = Paygate::Transaction.new(amount, bank_account, options)
      result = Paygate::Response.new(false, amount, "debit", options)
      
      path = "/paygate/edddirect.aspx"
      raw = transaction.to_params
      data = transaction.to_encrypted_params

      # prepare request
      request = "POST #{path} HTTP/1.0\r\n" + 
        "Host: www.netkauf.de\r\n" +
        "Connection: Close\r\n" +
        "Content-type: application/x-www-form-urlencoded\r\n" +
        "Content-Length: %s\r\n\r\n" +
        "#{data}"
      request = request % [length = data.length]

      #--- connect SSL socket
      # E.g. curl -v --header "Host: www.netkauf.de" --header "Connection: Close" --header "Content-type: application/x-www-form-urlencoded" --header "Content-Length: 653" --data "MerchantID=mschweizer&Len=229&Data=ECD4E85467B7DD2049C33A9C7AD619707C6604C6851CB6A87CC7EE674CA6A092487098275503F06776977E894A47B4F56A23706253B0D81F27C54E162AAB9DA37D7FAD14FFE6F235E4EDAD32283C4C56A9AF3C4E712826D5BCB8099B2FE9BA015DEF0CDF806074CA3DC1145D00AE61E526418607A4DF803501C8A96C2F11E91DE31E2EBC28FA9F6625B6C44AB1D8B77AA15E43400A6DB6EE398EFF3144E968E4970E6BB1B7BEBFADFECFBE627A07E9E95992BD4D1521707EE891831143B4F1B3A63A3D34524AF199DFF8778E365D0C4A0727840D75DCFFABAB7A6ECC5094B45EFE6B36F1F4C02D16" -X POST https://www.netkauf.de 
      connect("https://www.netkauf.de/paygate/edddirect.aspx") do |socket|

        puts "Raw -> " + raw
        puts "\r\n"
        puts "Encrypted data -> " + data
        puts "\r\n"
        puts "--- BEGIN REQUEST ---"
        puts request
        puts "--- END REQUEST ---"
        puts "\r\n"

        unless test?
          socket.write(request)
          puts "-> bytes written #{result}" 
          response = socket.read
          headers, body = response.split("\r\n\r\n", 2) 

          puts "--- BEGIN RESPONSE ---"
          puts headers
          puts "\r\n"
          puts body
          puts "--- END RESPONSE ---"
          
          result = process(amount, "debit", body, options)
        else
          result = Paygate::Response.new(true, amount, "debit", options)
        end

        puts "** finished at #{Time.now.utc}"
      end

      result
    end
    
    protected
    
    # process response and returns a result object
    def process(amount, action, response_body, options={})
      result = Paygate::Response.new(false, amount, "debit", options)
      response = Hash.from_url_params(response_body)
      if response['Len'] && response['Data']
        length = response[:Len].to_i
        encrypted_text = response['Data']
        raw_text = Blowfish.decrypt(encrypted_text, length)
        
        puts "-> raw response " + raw_text
        
        content = Hash.from_url_params(raw_text)

        status = case content['Status']
        when /FAILED/ then false
        when /OK/ then true
        else
          false
        end
        
        result = Paygate::Response.new(status, amount, action, 
          {:trans_id => content['TransID'], :pay_id => content['PayID'], :x_id => content['XID'],
            :description => content['Description'], :code => content['Code'], :m_id => content['mid']})
      end
      result
    end
    
    def connect(url)
      uri = URI.parse(url)
      socket = TCPSocket.open(uri.host, uri.port)
      ssl_context = OpenSSL::SSL::SSLContext.new #(:TLSv1_client)
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      ssl_socket.sync = true
      # ssl_socket.sync_close = true
      ssl_socket.connect
      puts "** SSL connected at #{Time.now.utc}, host: #{uri.host}, port: #{uri.port}"
      
      yield ssl_socket
      
      ssl_socket.close
      socket.close
      puts "** SSL connecion closed at #{Time.now.utc}, host: #{uri.host}, port: #{uri.port}"
    end

  end

  #--- encapsulates bank account info
  class Transaction
    
    def initialize(amount, bank_account, options={})
      if amount.is_a?(Money)
        @amount = amount
        @currency = amount.currency
      else
        @amount = amount
        @currency = options[:currency] || bank_account.currency
      end
      @bank_account = bank_account
      
      @merchant_id = options[:merchant_id] || Paygate.merchant_id
      @trans_id = options[:trans_id]
      @order_desc = options[:description_line_1]
      @order_desc2 = options[:description_line_2]
      @mac = options[:mac]
      @req_id = options[:red_id]
      @ip_addr = options[:ip_address]
      @ip_zone = options[:ip_zone]
    end
    
    def amount
      @amount.is_a?(Money) ? @amount.cents : @amount
    end
    
    #  MerchantID=mschweizer&AccBank=bank&Amount=200&AccNr=123456&AccOwner=owner&AccIBAN=44448888&OrderDesc=test&
    #    TransID=1216126620656&Currency=EUR
    def to_params
      result = []
      result << "MerchantID=#{@merchant_id}" if @merchant_id
      result << "TransID=#{@trans_id}" if @trans_id
      result << "Amount=#{amount.to_s.strip}" if @amount
      result << "Currency=#{@currency}" if @currency
      result << "AccNr=#{escape(@bank_account.account_number.to_s)}" if @bank_account
      result << "AccIBAN=#{escape(@bank_account.routing_number.to_s)}" if @bank_account
      result << "AccBank=#{escape(@bank_account.bank_name)}" if @bank_account
      result << "AccOwner=#{escape(@bank_account.account_owner)}" if @bank_account
      result << "OrderDesc=#{escape(@order_desc)}" if @order_desc
      result << "OrderDesc2=#{escape(@order_desc2)}" if @order_desc2
      result << "MAC=#{@mac.to_s.strip}" if @mac
      result << "ReqID=#{@req_id.to_s.strip}" if @req_id
      result << "IPAddr=#{@ip_addr.to_s.strip}" if @ip_addr
      result << "IPZone=#{@ip_zone.to_s.strip}" if @ip_zone
      result.reject(&:blank?).join("&")
    end 
   
    # MerchantID=mschweizer&Len=140&Data=ECD4E85467B7DD...
    def to_encrypted_params
      pm = self.to_params
      payload = Paygate::Blowfish.encrypt(pm)
      "MerchantID=#{@merchant_id}&Len=#{pm.length}&Data=#{payload}"
    end
    
    protected
    
    # for now, let's just remove all spaces
    def escape(value)
      value.to_s.strip.gsub(/\s/, '')
    end
  end
  
  #--- encapsulates bank account info
  class BankAccount
    def initialize(account_number, routing_number, bank_name, account_owner, options={})
      options = options.symbolize_keys
      @account_number = account_number
      @routing_number = routing_number
      @bank_name = bank_name
      @account_owner = account_owner
      @currency = options[:currency] || "EUR"
    end
    
    def account_number
      @account_number
    end

    def routing_number
      @routing_number
    end

    def bank_name
      @bank_name
    end
    
    def account_owner
      @account_owner
    end

    def currency
      @currency
    end
  end
  
  # represents a result value object for further processing upstream
  class Response
    attr_accessor :success
    attr_accessor :amount
    attr_accessor :action
    attr_accessor :trans_id
    attr_accessor :pay_id
    attr_accessor :x_id
    attr_accessor :m_id
    attr_accessor :description
    attr_accessor :code
    attr_accessor :params
    
    def initialize(success=false, amount=Money.new(0, 'USD'), action=:none, options={})
      defaults = {:description => nil, :authorization => nil}
      options = defaults.merge(options).symbolize_keys
      @success = success
      @amount = amount
      @action = action
      @code = options.delete(:code)
      @trans_id = options.delete(:trans_id)
      @pay_id = options.delete(:pay_id)
      @x_id = options.delete(:x_id)
      @m_id = options.delete(:m_id)
      @description = options.delete(:description)
      @params = options
    end
    
    def success?
      @success || false
    end
    
    def message
      @description
    end

    def trans_id
      @trans_id
    end
    alias_method :transaction, :trans_id

    def pay_id
      @pay_id
    end

    def x_id
      @x_id
    end
    alias_method :authorization, :x_id

    def params
      @params
    end
    
    def test?
      Paygate.test?
    end
  end
  
  #--- blowfish encryption stuff
  class Blowfish
    class << self
    
      def encrypt(plain_text, password=nil)
        @blowfish = Crypt::Blowfish.new(password || Paygate.password)
        cipher = expand(plain_text)
        cipher = encrypt_blocks(cipher)
        cipher = int2hex(cipher)
        cipher
      end

      def decrypt(encrypted_text, length, password=nil)
        @blowfish = Crypt::Blowfish.new(password || Paygate.password)
        cipher = hex2int(encrypted_text)
        cipher = decrypt_blocks(cipher)
        cipher = cipher[0, length] if length
        cipher
      end

      protected
    
      def encrypt_blocks(plain_text)
        result = []
        until plain_text.blank?
          block = plain_text[0, 8]
          result << @blowfish.encrypt_block(block)
          plain_text[0, 8] = ""
        end
        result.join
      end

      def decrypt_blocks(encrypted_text)
        result = []
        until encrypted_text.blank?
          block = encrypted_text[0, 8]
          result << @blowfish.decrypt_block(block) if block.size == 8
          encrypted_text[0, 8] = ""
        end
        result.join
      end
    
      # E.g. "abc" -> "abcxxxxx" 
      def expand(text)
        ln = text.length
        nb = (ln % 8) > 0 ? ((((ln - (ln % 8)) >> 3) + 1) << 3) : ln
        if ln < nb
          until text.length == nb do
            text += "x"
          end
        end
        text
      end
    
      # E.g. "AB" -> "4142"
      def int2hex(int_string)
        result = []
        int_string.each_byte do |char|
          result << char.to_s(16).rjust(2, "0").upcase
        end
        result.join
      end

      # E.g. "4142" -> "AB"
      def hex2int(hex_string)
        hex_string.split(/([a-fA-F0-9][a-fA-F0-9])/i).reject(&:blank?).map {|h| h.to_i(16)}.map(&:chr).join
      end
    end
  end

  class PaygateError < Exception
  end
  
end