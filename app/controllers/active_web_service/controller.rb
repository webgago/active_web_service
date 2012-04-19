require "active_web_service/soap_request"

module ActiveWebService
  class Controller < ActionController::Base
    abstract!

    self.allow_forgery_protection = false

    DEFAULT_PROTECTED_INSTANCE_VARIABLES << "@_soap_request"

    def index
      raise RoutingError.new "index action should not call for soap"
    end

    def dispatch(name, request)
      @_request      = request
      @_soap_request = SoapRequest.new(request.raw_post, wsdl_document, wsdl_binding)

      rewrite_action(soap_request.operation)

      request.path_parameters['format'] = 'xml'
      super(soap_request.operation, request)
    end

    def soap_request
      @_soap_request
    end

    def rewrite_action(action)
      raise "New action is blank!" if action.blank?
      request.path_parameters[:action] = action
    end

    private :rewrite_action

    def process_action(action_name)
      super(action_name)
    end


    class_attribute :wsdl_location, :instance_reader => true, :instance_writer => false
    class_attribute :wsdl_document, :instance_reader => true
    class_attribute :wsdl_binding, :instance_reader => true

    def self.wsdl(location, binding = nil)
      self.wsdl_location = location
      self.wsdl_document = WSDL::Reader::Parser.new(location)
      self.wsdl_binding  = binding
    end

  end
end

#ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::Type.lookup('application/vnd.xxx_v1+json')]=lambda do |body|
#  JSON.parse(body)
#end
#
#http://stackoverflow.com/questions/8700332/rails-3-and-json-default-renderer-but-custom-mime-type
