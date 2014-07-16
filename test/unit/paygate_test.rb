require File.dirname(__FILE__) + '/../test_helper'

class PaygateTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    Paygate.merchant_id = "rsmith"
    Paygate.password = "ax[!Z67"
    Paygate.test = true
    
    @bank_account = build_bank_account
    
  end
  
  def test_should_int2hex_and_hex2int
    original = "MerchantID=mschweizer&AccBank=bank&Amount=200&AccNr=123456&AccOwner=owner&AccIBAN=44448888&OrderDesc=test&TransID=1216126620656&Currency=EUR"
    hex = Paygate::Blowfish.send(:int2hex, original)
    string = Paygate::Blowfish.send(:hex2int, hex)
    assert_equal original, string
  end
  
  def test_should_hexinverse
    hex_string = "ECD4E85467B7DD2049C33A9C7AD619702929381925382A3727882D5C21C220401CDCCC16858DA8385F609497A022E4146BA6F288AEDFE261A9F5FB3BFCF14EE724E06384756DFD7682936628A3BDDF2FD3B217B926584E239DF760DD784B2311A849395C77FFB51A5EC9D78B9D39B603887AD2C3C6E955CCCE8737292C27C54E162AAB9DA3BF6DB23090F3B025"
    hex_string.split(/([a-fA-F0-9][a-fA-F0-9])/i).reject(&:blank?).each do |hex_value|
      int_value = Paygate::Blowfish.send(:hex2int, hex_value)
      hex_result = Paygate::Blowfish.send(:int2hex, int_value)
      # puts "-> #{hex_value} -> int_value #{int_value} -> hex_result #{hex_result}"
      assert_equal hex_value, hex_result
    end
  end
  
  def test_should_encrypt_and_descrypt
    param = "MerchantID=mschweizer&AccBank=bank&Amount=200&AccNr=123456&AccOwner=owner&AccIBAN=44448888&OrderDesc=test&TransID=1216126620656&Currency=EUR"
    length = param.length
    assert_equal 140, length
    encrypted = Paygate::Blowfish.encrypt(param)
    decrypted = Paygate::Blowfish.decrypt(encrypted, length)
    assert_equal param, decrypted
  end
  
  def test_should_parameterize_bank_account_information
    transaction = Paygate::Transaction.new(Money.new(200, "EUR"), @bank_account,   
      {:trans_id => "1216126620656", :description_line_1 => "kann-ich-klagen.de 20-er Paket", :description_line_2 => "Rechnungsnr.: 000001021010",
        :red_id => "c3a45e9", :ip_address => "192.168.1.1", :ip_zone => "200,201,202", :mac => "intosh"})
    params = transaction.to_params
    assert_equal "MerchantID=rsmith&TransID=1216126620656&Amount=200&Currency=EUR&AccNr=958586&AccIBAN=72151680&AccBank=SparkasseIngolstadt&AccOwner=JuergenFesslmeier&OrderDesc=kann-ich-klagen.de20-erPaket&OrderDesc2=Rechnungsnr.:000001021010&MAC=intosh&ReqID=c3a45e9&IPAddr=192.168.1.1&IPZone=200,201,202",
      params
  end

  def test_should_encrypt_parameterized_bank_account_information
    transaction = Paygate::Transaction.new(Money.new(200, "EUR"), @bank_account, 
      {:trans_id => "1216126620656", :description_line_1 => "kann-ich-klagen.de 20-er Paket", :description_line_2 => "Rechnungsnr.: 000001021010",
        :red_id => "c3a45e9", :ip_address => "192.168.1.1", :ip_zone => "200,201,202", :mac => "intosh"})
        
    ep = transaction.to_encrypted_params
    assert_equal "MerchantID=rsmith&Len=287&Data=363C3597F27BF04FDD86A851D291B6D87365068908D37C0E5D10AA25AACB0057789AB4AEF7FF49039B8B22936F468EEB10E8CC111E6D1A27A63F1E4389C045E5E98E91457B5266A4B4A4FF5D86760ABEEDE595C4510528E491C4E72840D34A3A52291E86DC223A043E0EBC07DE17D16993E47B55613D880D8EA517A36D4FAB7B7D1FE8BD7B4DA6E94E10ECBBD52713DEC4C53AC914D1AD9B2FC83922643F27F0376156B0B50E8CB95D0CE6A17C19671B3DBD76CD6A689EF29303638735721417E4FE803D70B3D8D134A4AD2166F8B313E3CA7E8A5EE9FEA86955DD034CBBB2325DDE7B9BD9BF6B5B2B9555C142738D1C109C72EB7A465F8D5CA555BCDE315E06AD9A542A075B2CB01AF13CCF29B1E37122EA17AC294E234C005F74512AF2007B", ep
  end
  
  def test_should_to_params_with_transaction
    transaction = Paygate::Transaction.new(Money.new(1256, "USD"), @bank_account, valid_debit_options)
    assert_equal "MerchantID=rsmith&TransID=1216126620656&Amount=1256&Currency=USD&AccNr=958586&AccIBAN=72151680&AccBank=SparkasseIngolstadt&AccOwner=JuergenFesslmeier&OrderDesc=kann-ich-klagen.de20-erPaket&OrderDesc2=Rechnungsnr.:000001021010",
      transaction.to_params
  end

  def test_should_to_params_with_transaction
    transaction = Paygate::Transaction.new(Money.new(1256, "USD"), @bank_account, valid_debit_options)
    assert_equal "MerchantID=rsmith&Len=225&Data=363C3597F27BF04FDD86A851D291B6D87365068908D37C0E5D10AA25AACB0057789AB4AEF7FF49031BFCE0DB96E8E676C1DF9D52E9403B581400F31A017370610137577D66A19551F4899411ED52192B764ACF0A3375056987B9CE95F3052AD46D0D626538B3976E80FC8119D2A65E7708EADF1AA743E465B7C43B2CFFD9861568B5392ED54402608FDAB866CCCA94F01CE82B648240B9D382BD64A8244AC28976F0BD5A88031BE5BFDD63A2E28B5566CBAC5267B8C81C78EE4D54331CB63B3D9746A6D92923E4544C2D5BF55C99B71304DD1A0975C699F6A8FFED18BFEA132066D651250454A522",
      transaction.to_encrypted_params
  end
  
  def test_should_encode_with_computop_example
    original = "MerchantID=mschweizer&AccBank=bank&Amount=200&AccNr=123456&AccOwner=owner&AccIBAN=44448888&OrderDesc=test&TransID=1216126620656&Currency=EUR"
    expected = "ECD4E85467B7DD2049C33A9C7AD619702929381925382A3727882D5C21C220401CDCCC16858DA8385F609497A022E4146BA6F288AEDFE261A9F5FB3BFCF14EE724E06384756D0FD7682936628A3BDDF20FD3B217B926584E239DF760DD784B020311A849395C77FFB51A5EC9D78B9D390B 603887AD2C3C6E0955CCCE8737292C27C54E162AAB9DA34A1C71B300E3FBFC"
    encrypted = Paygate::Blowfish.encrypt(original, "b!3X)Zk9c2N]Co[5")
    assert expected, encrypted
  end
  
  def test_should_debit
    Paygate.merchant_id = "mschweizer"
    Paygate.password = "b!3X)Zk9c2N]Co[5"
    Paygate.test = false
    
    result = Paygate.debit(Money.new(3750, "EUR"), @bank_account, 
      valid_debit_options)
      
    assert_equal true, result.success?
    assert_equal "debit", result.action
    assert_equal "VALID", result.description
    assert_equal "00000000", result.code
    assert_equal "37,50 €", result.amount.format
    assert_equal "mschweizer", result.m_id
    assert result.trans_id, "should have a trans id"
    assert result.pay_id, "should have a pay id"
    assert result.x_id, "should have a x id (auth)"
  end

  def test_should_fake_debit
    Paygate.test = true
    amount = Money.new(3750, "EUR")
    result = Paygate.debit(amount, @bank_account, 
      valid_debit_options)
    assert_equal true, result.success?
    assert_equal true, result.test?
    assert_equal "37,50 €", result.amount.format
  end

  protected
  
  def valid_debit_options(options={})
    {
      :trans_id => "1216126620656",
      :description_line_1 => "kann-ich-klagen.de 20-er Paket", 
      :description_line_2 => "Rechnungsnr.: 000001021010"
    }.merge(options)
  end
  
  def all_debit_options(options={})
    {
      :trans_id => "1216126620656",
      :description_line_1 => "kann-ich-klagen.de 20-er Paket", 
      :description_line_2 => "Rechnungsnr.: 000001021010",
      :red_id => "c3a45e9", 
      :ip_address => "192.168.1.1", 
      :ip_zone => "200,201,202", 
      :mac => "intosh"
    }.merge(options)
  end

  def build_bank_account(account_number=nil, routing_number=nil, bank_name=nil, owner_name=nil)
    Paygate::BankAccount.new(account_number || "6540469332",
      routing_number || "70020270", bank_name || "HypoVereinsbank", owner_name || "Michael Schweizer")
  end
end
