require "active_web_service/version"
require "abstract_controller"
require "action_controller"
require "wsdl-reader"
require "libxml"

module ActiveWebService
  extend ActiveSupport::Autoload

  autoload :Type
  autoload :TypeManager
  autoload :TypeDefiner
  autoload :Attribute
  autoload :Document
  autoload :DocumentTypes
  autoload :Envelope
  autoload :Controller
  autoload :XSLTRewrite

  NAMESPACES = { }


  mattr_accessor :ns_num
  self.ns_num = 0

  def self.prepend_ns(tag, namespace)
    return tag if namespace.blank?

    ns = NAMESPACES[namespace] ||= begin
      ::ActiveWebService.ns_num = ::ActiveWebService.ns_num + 1
      "ns#{::ActiveWebService.ns_num}"
    end
    "#{ns}:#{tag}"
  end

  def self.xmlns_attributes
    NAMESPACES.inject({ }) do |hash, (k, v)|
      hash.merge({ k => "xmlns:#{v}" })
    end.invert
  end

end


ActionController::Renderers.add :soap do |soap, options|
  self.content_type ||= Mime::XML
  env = ActiveWebService::Envelope.new soap, options.delete(:header), options
  env.to_xml
end
