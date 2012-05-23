require "active_web_service/version"
require "abstract_controller"
require "action_controller"
require "wsdl-reader"
require "libxml"
require "savon_model"
require "active_web_service/soap_request"
require "active_web_service/soap_data_hash"

module ActiveWebService
  extend ActiveSupport::Autoload

  autoload :Controller
  autoload :Client
  autoload :ViewData
end

