require "active_support/inflector"
module ActiveWebService
  class TypeDefiner
    attr_reader :xsd_type, :struct_class

    def initialize(xsd_type, parent)
      @xsd_type, @parent = xsd_type, parent
      @struct_name = xsd_type.name.name
      @attribute_names = extract_attributes
    end

    def define
      return if @parent.const_defined? @struct_name
      define_struct
      define_attributes
      #define_validations(type) unless type.members.blank?
    end

    def define_struct
      @struct_class = @parent.new @struct_name, *@attribute_names
      @struct_class.xsd_type = xsd_type
    end

    def extract_attributes
      xsd_type.nested_elements.to_a.map { |e| e.name.name.underscore }
    end

    def define_attributes
      struct_class.attributes = xsd_type.nested_elements.to_a.map do |e|
        Attribute.new(e.name, e.type.name)
      end
    end

    def define_validations(type)
      type.validates_each(*type.members) do |record, attr, value|
        record.errors.add attr, 'present' if value.blank?
      end
      type.validates_presence_of *attributes.select { |k, v| v.minoccurs > 0 }.keys
    end

  end
end
