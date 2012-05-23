module ActiveWebService
  class Client
    class_attribute :controller_path, :service, :enable, :disabled_actions, :default_xml_namespaces
    self.controller_path = name.sub(/Client$/, '').underscore unless anonymous?
    self.default_xml_namespaces = {}

    include AbstractController::Rendering
    include AbstractController::Layouts
    include ActionController::Helpers

    include Savon::Model

    self.helpers_path << 'app/helpers'
    self.prepend_view_path 'app/views'

    helper ApplicationHelper
    helper_method :service, :xml_namespaces

    def self.abstract?
      true
    end

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

    private

    def xml_namespaces(namespaces = { })
      default_xml_namespaces.reverse_merge namespaces
    end

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