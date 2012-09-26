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

    private

    def request
      with_logging do
        self.last_request  = create_request
        self.last_response = HTTPI.post(self.last_request)
      end
    end

    alias_method :send_request, :request

    def create_request
      HTTPI::Request.new.tap do |request|
        request.url                       = endpoint
        request.body                      = request_body
        request.headers["Content-Type"]   ||= "text/xml;charset=UTF-8"
        request.headers["Content-Length"] ||= request_body.length.to_s
      end
    end

    def call(*)
      send_request
    end

    def with_logging
      time = Time.now.to_i
      Redis.current.sadd 'outcoming', time
      Redis.current.hset 'requests', time, request_body

      begin
        result = yield
        Redis.current.hset 'responses', time, last_response.body
      rescue StandardError => e
        Redis.current.hset 'responses', time, [e.class.name, e.message, e.backtrace.join("\n")].join("\n")
        raise e
      end

      result
    end
  end
end
