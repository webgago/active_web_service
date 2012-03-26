module ActiveWebService
  class Attribute
    attr_reader :soap_name, :klass_name, :klass, :namespace

    def initialize(qname, klass_name)
      @soap_name = qname.name
      @klass_name = klass_name
      @klass = nil
      @namespace = qname.namespace
    end

    def name
      @soap_name.underscore
    end

    def method_name
      name.to_sym
    end

    def tag_name(self_closing=false)
      result = soap_name.dup
      result = self_closing ? result + "/" : result
      ActiveWebService.prepend_ns result, namespace
    end

    def klass
      @klass ||= begin
        TypeManager.find @klass_name
      rescue TypeNotFoundError
        @klass_name
      end
    end

    def cast(value)
      return if value.nil?
      case klass
        when 'decimal'
          value.to_f
        when 'int'
          value.to_i
        when 'string'
          value.to_s
        when 'dateTime'
          DateTime.parse(value)
        when 'date'
          Date.parse(value)
        when 'time'
          Time.parse(value)
        when Class
          klass.new value
        else
          warn "Undefined type on attribute cast: #{klass}"
      end
    end

  end
end

