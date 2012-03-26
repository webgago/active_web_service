module ActiveWebService

  class Type < Struct
    class Simple

      def initialize(value)
        @value = value
      end

      def type
        @type ||= Type.document.types.simple.find { |t| t.name.name =~ /#{self.class.name.demodulize}/i }
      end

      def options
        type.try(:restriction).try(:enumeration)
      end

      def pattern
        type.try(:restriction).try(:pattern)
      end

      def to_s
        @value
      end

      def inspect
        "#<#{self.class.name} #{@value}>"
      end

    end

    class_attribute :document, :xsd_type, :attributes

    extend ActiveModel::Translation
    include ActiveModel::Validations

    def initialize(attributes = { })
      self.attributes.each do |attribute|
        self.send "#{attribute.name}=".to_sym, attribute.cast(attributes[attribute.soap_name])
      end unless attributes.blank?
    end

    def blank?
      values.all? &:blank?
    end

    def element
      @element ||= document.elements.values.find { |e| e.type == self.xsd_type.name }
    end

    def to_xml_hash
      if element
        { tag_name => attributes_hash }.tap do |hash|
          hash[:attributes!] = { tag_name => ActiveWebService.xmlns_attributes }
        end
      else
        attributes_hash
      end
    end

    def attributes_hash
      self.attributes.inject({ }) do |hash, attr|
        attribute_value = send(attr.method_name)
        value = attribute_value.send attribute_value.is_a?(Type) ? :to_xml_hash : :to_s
        tag = attr.tag_name(value.blank?)
        hash[tag] = value
        hash
      end
    end

    def to_xml(options = { })
      Gyoku.xml to_xml_hash
    end

    def xsd_type
      @xsd_type ||= document.find(self.class.name.demodulize)
    end

    def tag_name
      return if element.nil?
      @tag_name ||= ActiveWebService.prepend_ns(element.name.name, element.name.namespace)
    end
  end

end
