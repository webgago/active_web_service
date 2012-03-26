module ActiveWebService
  class Controller < ::ApplicationController
    skip_before_filter :verify_authenticity_token

    class_attribute :wsdl_location, :instance_reader => false, :instance_writer => false
    class_attribute :document

    class << self

      def wsdl(location)
        self.wsdl_location ||= location
        self.document ||= ActiveWebService::Document.new(wsdl_location)
      end

      def soap_actions
        self.document.actions
      end

    end

    before_filter :setup_soap_request

    def method_for_action(action_name)
      soap_action || super
    end

    def action_method?(name)
      soap_action?(name) && super
    end

    def soap_action?(name)
      self.class.soap_actions.include?(name)
    end

    def soap_action
      @soap_action = begin
        params['soap_action'] = params['Envelope']['Body'].keys.first.underscore
      rescue NoMethodError
        nil
      end
    end

    def setup_soap_request
      @_soap_request = document.request_for(soap_action, fill: soap_body)
    end

    def soap_body
      params['Envelope'].present? && params['Envelope']['Body'].present? &&
          params['Envelope']['Body'].first.last
    end

    def soap_request
      @_soap_request
    end
  end
end