require "active_web_service/soap_request"

module ActiveWebService
  class Controller < ActionController::Base
    abstract!

    self.allow_forgery_protection = false

    class_attribute :wsdl_location, :instance_reader => true, :instance_writer => false
    class_attribute :wsdl_document, :instance_reader => true
    class_attribute :wsdl_binding, :instance_reader => true
    class_attribute :default_format, :service, :default_xml_namespaces

    self.default_format = 'xml'
    self.default_xml_namespaces = {}

    helper_method :service, :xml_namespaces


    def self.wsdl(location, binding = nil)
      self.wsdl_location = location
      self.wsdl_document = WSDL::Reader::Parser.new(location)
      self.wsdl_binding  = binding
    end

    DEFAULT_PROTECTED_INSTANCE_VARIABLES << "@_soap_request"

    def initialize(*)
      super
      self.formats = ['xml']
    end

    def index
      raise ActionController::RoutingError.new "index action should not be called with soap\n request: #{soap_request}"
    end

    def dispatch(name, request)
      make_soap_request(name, request)
      super(soap_request.operation, request)
    end

    def make_soap_request(name, request)
      @_request      = request
      @_soap_request = SoapRequest.new(request.raw_post, wsdl_document, wsdl_binding)

      rewrite_action_and_format(soap_request.operation, self.class.default_format)
    end

    def soap_request
      @_soap_request
    end

    def process(action, *args)
      make_soap_request(action, request) unless @_soap_request
      super(request.symbolized_path_parameters[:action])
    end

    private

    def rewrite_action_and_format(action, format)
      request.path_parameters = request.path_parameters.merge('action' => action, 'format' => format)
    end

    def xml_namespaces(namespaces = { })
      default_xml_namespaces.reverse_merge namespaces
    end

  end
end

#ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::Type.lookup('application/vnd.xxx_v1+json')]=lambda do |body|
#  JSON.parse(body)
#end
#
#http://stackoverflow.com/questions/8700332/rails-3-and-json-default-renderer-but-custom-mime-type
