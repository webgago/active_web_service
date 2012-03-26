module ActiveWebService
  class TypeNotFoundError < StandardError;
  end

  class TypeManager
    def self.define(xsd_type)
      TypeDefiner.new(xsd_type, Type).define
    end

    def self.define_simple(xsd_type)
      const_name = xsd_type.name.name.camelize
      Type::Simple.const_set(const_name, Class.new(Type::Simple)) unless Type::Simple.const_defined?(const_name)
    end

    def self.find(type)
      name = type.is_a?(String) ? type : type.name.name
      Type.const_get(name.to_sym)
    rescue NameError
      begin
        Type::Simple.const_get(name.camelize.to_sym, false)
      rescue NameError
        raise TypeNotFoundError
      end
    end
  end
end
