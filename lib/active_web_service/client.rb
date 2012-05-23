module ActiveWebService
  class Client
    def self.controller_path
      name.sub(/Client$/, '').underscore unless anonymous?
    end

    class_attribute :service, :enable, :disabled_actions, :default_xml_namespaces
    class_attribute :wsdl_location, :wsdl_document, :wsdl_binding

    self.enable = true
    self.disabled_actions = []
    self.default_xml_namespaces = {}

    include AbstractController::Rendering
    include AbstractController::Layouts
    include ActionController::Helpers

    include Savon::Model

    self.helpers_path << 'app/helpers'
    self.prepend_view_path 'app/views'

    helper ApplicationHelper if Object.const_defined? :ApplicationHelper
    helper_method :service, :xml_namespaces


    def self.bind(url_and_binding_name = { })
      self.wsdl_location, binding_name = url_and_binding_name.first
      self.wsdl_document = WSDL::Reader::Parser.new(self.wsdl_location)
      self.wsdl_binding  = wsdl_document.bindings[binding_name]

      raise ArgumentError, "binding name '#{binding_name}' not found in wsdl '#{self.wsdl_location}'" unless self.wsdl_binding

      self.document(self.wsdl_location)
      self.endpoint(self.wsdl_binding.service_address(self.wsdl_document.services))
    end

    class << self
      attr_reader :abstract
      alias_method :abstract?, :abstract

      def abstract!
        @abstract = true
      end
    end

    abstract!

    attr_accessor :response_body, :action_name
    alias request_body response_body
    alias request_body= response_body=

    def initialize(*)
      super
      self.formats = ['xml']
    end

    def controller_path
      self.class.controller_path
    end

    def callable?(action)
      enable && action.not_in?(disabled_actions)
    end

    def xml_namespaces(namespaces = { })
      default_xml_namespaces.merge namespaces
    end

    private

    def call(action)
      unless callable? action
        client.request :type, action.to_s, namespaces do
          soap.body    = request_body
          http.headers = { }
        end
      end
    end
  end
end