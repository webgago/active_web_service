require "nokogiri"
require "active_web_service/errors"

module ActiveWebService
  class SoapRequest

    attr_reader :xml, :wsdl, :binding, :binding_name

    def initialize(xml, wsdl, binding_name = nil)
      @xml, @wsdl, @binding_name = xml, wsdl, binding_name
      setup_binding
    end

    # @return [Nokogiri::XML::Document]
    def xml_document
      @xml_document ||= parse_input_data(xml)
    end

    def operation
      @operation ||= lookup_operation.method_name
    rescue WSDL::Reader::LookupError => e
      raise ActionController::RoutingError, e.message
    end

    # @return [String]
    def element_name
      element.name
    end

    # @return [Nokogiri::XML::Node]
    def element
      @element ||= xml_document.xpath('//soap:Body/*[1]', 'soap' => 'http://schemas.xmlsoap.org/soap/envelope/').first.tap do |e|
        raise SoapRequestError, "Could not found message element" if e.nil? || !e.respond_to?(:name) || e.name.blank?
      end
    end

    def operations
      binding ? wsdl.operations(binding.name) : wsdl.operations
    end

    def port_types
      binding ? wsdl.port_types[binding.type_nns] : wsdl.port_types
    end

    private

    def setup_binding
      return unless @binding_name.present?
      @binding = wsdl.bindings[@binding_name]

      unless @binding.present?
        raise ArgumentError, "binding '#{@binding_name}' not found in #{wsdl.location}"
      end
    end

    def lookup_operation
      op = wsdl.lookup_operation_by_element!(:input, element_name, port_types)
      operations[op] ? operations[op] : raise(WSDL::Reader::OperationNotFoundError.new(:input, element_name))
    end

    def parse_input_data(raw_post)
      Nokogiri::XML(raw_post)
    end

  end
end
