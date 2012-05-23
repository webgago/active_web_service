require "active_web_service/version"
require "abstract_controller"
require "action_controller"
require "wsdl-reader"
require "libxml"

require "active_web_service/soap_request"

module ActiveWebService
  extend ActiveSupport::Autoload

  autoload :Controller
  autoload :Client
end

