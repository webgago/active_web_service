require "nokogiri"

module ActiveWebService
  class SoapRequest

    attr_reader :xml, :wsdl, :binding
    protected :xml, :wsdl

    def initialize(xml, wsdl, binding = nil)
      @xml, @wsdl, @binding = xml, wsdl, wsdl.bindings[binding]
    end

    def operation
      @operation ||= lookup_operation.method_name
    rescue WSDL::Reader::LookupError => e
      raise ActionController::RoutingError, e.message
    end

    def element
      @element ||= xml_doc.xpath('//Body/*[1]').first
    end

    def operations
      binding ? wsdl.operations(binding.name) : wsdl.operations
    end

    def port_types
      binding ? wsdl.port_types[binding.type_nns] : wsdl.port_types
    end

    private

    def lookup_operation
      op = wsdl.lookup_operation_by_element!(:input, element.name, port_types)
      operations[op] ? operations[op] : raise(WSDL::Reader::OperationNotFoundError.new(:input, element.name))
    end

    def xml_doc
      @xml_doc ||= parse_input_data(xml)
    end

    def parse_input_data(raw_post)
      document = Nokogiri.parse raw_post
      document.remove_namespaces!
    end

  end
end