require 'wsdl/importer'
require 'wsdl/xml_schema/importer'
require "active_web_service/type"
require "active_web_service/document_types"
require "active_web_service/attribute"

module ActiveWebService

  class Document

    attr_accessor :definitions, :types

    def initialize(location)
      Type.document = self
      @definitions = WSDL::Importer.import(location)
      @types = DocumentTypes.new(@definitions)
    end

    def operations
      @operations ||= binding.operations.inject({ }) do |hash, op|
        hash[op.name] = op
        hash
      end
    end

    def operation_names
      operations.keys
    end

    def binding(method=:first)
      definitions.bindings.send(method)
    end

    def actions
      operations.keys.map(&:underscore)
    end

    def response_for(action)
      operations[action.camelize(:lower)].operation_info.parts.last.element.name
    end

    def request_for(action, options = {})
      return {} if action.nil?

      element_name = operations[action.camelize(:lower)].operation_info.parts.first.element.name
      request = type_by_element_name(element_name)
      request = map(request, options[:fill]) if options[:fill]
      request
    end

    def type_by_element_name(name)
      element = elements[name]
      element ? types[element.type.name] : nil
    end

    def find(name)
      types[name] || elements[name] || messages[name]
    end

    def map(type, data)
      TypeManager.find(type).new data
    end

    def elements
      @elements ||= definitions.collect_elements.to_a.inject({ }) do |hash, element|
        hash[element.name.name] = element
        hash
      end
    end

    def messages
      @messages ||= definitions.messages.inject({ }) do |hash, message|
        hash[message.name.name] = message
        hash
      end
    end

    def fault_types
      @fault_types ||= definitions.collect_faulttypes.to_a
    end

  end
end
