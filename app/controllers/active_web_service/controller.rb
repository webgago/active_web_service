require 'nokogiri'

module ActiveWebService
  class Controller < ActionController::Base
    abstract!

    self.allow_forgery_protection = false

    class_attribute :wsdl_location, :instance_reader => false, :instance_writer => false
    class_attribute :document

    DEFAULT_PROTECTED_INSTANCE_VARIABLES << "@_soap_action" << "@_soap_document_request"

    class << self

      def wsdl(location)
        self.wsdl_location ||= location
        self.document ||= WSDL::Reader::Parser.new(location)
      end

    end

    def index
      raise RoutingError.new "index action called!"
    end

    def dispatch(name, request)
      @_request = request
      @_soap_document_request = parse_input_data(request.raw_post)
      @_soap_action = extract_soap_action(request.raw_post)
      swap_actions @_soap_action, name
      super(@_soap_action, request)
    end

    def parse_input_data(raw_post)
      document = Nokogiri.parse raw_post
      document.remove_namespaces!
    end
    private :parse_input_data

    def extract_soap_action(raw_post)
      begin
        @_soap_document_request.xpath('//Body/*[1]').first.name.underscore
      end
    end
    private :extract_soap_action

    def swap_actions(new_action, old_action)
      raise "New action is blank!" if new_action.blank?
      request.env['action_dispatch.request.original_action'] = old_action
      request.env['action_dispatch.request.path_parameters']['action'] = new_action
      request.env['action_dispatch.request.path_parameters']['format'] = 'xml'
    end
    private :swap_actions

    def process_action(action_name)
      super
    end

    def action_name
      @_soap_action
    end

    def method_for_operation_name(name)
      name.to_s.underscore.to_sym
    end

    def to_ruby_method_name(name)
      case name
        when String
          name.underscore
        when Symbol
          name.to_s.underscore.to_sym
        else
          name.to_s.underscore
      end
    end

  end
end

#ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::Type.lookup('application/vnd.xxx_v1+json')]=lambda do |body|
#  JSON.parse(body)
#end
#
#http://stackoverflow.com/questions/8700332/rails-3-and-json-default-renderer-but-custom-mime-type
