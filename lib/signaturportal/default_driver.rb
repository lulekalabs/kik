require File.expand_path(File.dirname(__FILE__) + "/default.rb")
require File.expand_path(File.dirname(__FILE__) + "/default_mapping_registry.rb")
require 'soap/rpc/driver'

class MyServiceHandler < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://www.signaturportal.de:8095"
  NsC_8095 = "http://www.signaturportal.de:8095"

  Methods = [
    [ XSD::QName.new(NsC_8095, "test"),
      "",
      "test",
      [ ["retval", "testReturn", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "test_param"),
      "",
      "test_param",
      [ ["in", "text", ["::SOAP::SOAPString"]],
        ["retval", "test_paramReturn", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "sign"),
      "",
      "sign",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "dateiname", ["::SOAP::SOAPString"]],
        ["in", "data", ["::SOAP::SOAPBase64"]],
        ["retval", "signReturn", ["::SOAP::SOAPBase64"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "sign_extern"),
      "",
      "sign_extern",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "dateiname", ["::SOAP::SOAPString"]],
        ["in", "data", ["::SOAP::SOAPBase64"]],
        ["retval", "sign_externReturn", ["::SOAP::SOAPBase64"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "verify"),
      "",
      "verify",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "dateiname", ["::SOAP::SOAPString"]],
        ["in", "data", ["::SOAP::SOAPBase64"]],
        ["retval", "verifyReturn", ["::SOAP::SOAPBase64"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "verify_extern"),
      "",
      "verify_extern",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "dateiname", ["::SOAP::SOAPString"]],
        ["in", "data", ["::SOAP::SOAPBase64"]],
        ["in", "sigdateiname", ["::SOAP::SOAPString"]],
        ["in", "sigdata", ["::SOAP::SOAPBase64"]],
        ["retval", "verify_externReturn", ["::SOAP::SOAPBase64"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "balance"),
      "",
      "balance",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["retval", "balanceReturn", ["::SOAP::SOAPInt"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "transfer"),
      "",
      "transfer",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "targetkontoNr", ["::SOAP::SOAPInt"]],
        ["in", "amount", ["::SOAP::SOAPUnsignedInt"]],
        ["retval", "transferReturn", ["::SOAP::SOAPInt"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsC_8095, "timestamp"),
      "",
      "timestamp",
      [ ["in", "username", ["::SOAP::SOAPString"]],
        ["in", "passwort", ["::SOAP::SOAPString"]],
        ["in", "kontoNr", ["::SOAP::SOAPInt"]],
        ["in", "dateiname", ["::SOAP::SOAPString"]],
        ["in", "data", ["::SOAP::SOAPBase64"]],
        ["retval", "timestampReturn", ["::SOAP::SOAPBase64"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

