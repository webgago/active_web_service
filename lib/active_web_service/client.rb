module ActiveWebService
  class Client
    class EndpointResolver
      def self.call(wsdl_location_and_binding_name)
        wsdl_location = wsdl_location_and_binding_name[:location]
        binding_name  = wsdl_location_and_binding_name[:name]
        wsdl_document = WSDL::Reader::Parser.new(wsdl_location)
        wsdl_binding  = wsdl_document.bindings[binding_name]

        raise ArgumentError, "binding name '#{binding_name}' not found in wsdl '#{wsdl_location}'" unless wsdl_binding

        wsdl_binding.service_address(wsdl_document.services)
      end
    end

    class_attribute :enable, :disabled_actions
    class_attribute :service, :endpoint, :wsdl_location_and_binding_name

    self.disabled_actions = []
    self.enable           = true

    def self.bind(wsdl_location_and_binding_name = { })
      self.wsdl_location_and_binding_name = wsdl_location_and_binding_name
    end

    attr_reader :request_element
    attr_accessor :last_response, :last_request
    attr_accessor :request_body, :action_name

    def initialize(endpoint_resolver=EndpointResolver)
      self.class.endpoint = endpoint_resolver.call(wsdl_location_and_binding_name) unless self.endpoint
    end

    def send_request(xml, success=nil, failure=nil)
      self.request_body = xml

      self.last_request  = create_request
      self.last_response = HTTPI.post(self.last_request)

      if failure && last_response.respond_to?(:error?) && last_response.error?
        failure.call self
      else
        success && success.call(self)
      end

      last_response
    end

    private

    def create_request
      HTTPI::Request.new.tap do |request|
        request.url                       = endpoint
        request.body                      = request_body
        request.headers["Content-Type"]   ||= "text/xml;charset=UTF-8"
        request.headers["Content-Length"] ||= request_body.length.to_s
      end
    end

  end
end
