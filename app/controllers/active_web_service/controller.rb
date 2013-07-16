require "active_web_service/soap_request"

module ActiveWebService
  class Controller < ActionController::Metal
    class_attribute :default_format, :default_content_type

    self.default_format = 'xml'
    self.default_content_type = 'text/xml;charset=UTF-8'

    def process(name)
      @_request = request
      @_env = request.env
      @_env['action_controller.instance'] = self
      self.content_type  = self.default_content_type
      self.response_body = @_env['response.body']
    end
  end
end
