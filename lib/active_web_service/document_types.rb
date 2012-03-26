module ActiveWebService
  class DocumentTypes < Hash
    attr_reader :simple, :complex, :classes

    def initialize(definitions)
      @definitions = definitions
      @complex, @simple = [], []
      collect_types
      reorder
      fill
      define_types
    end

    private

    def define_types
      complex.each do |type|
        TypeManager.define(type)
      end

      simple.each do |type|
        TypeManager.define_simple(type)
      end
    end

    def fill
      (@complex + @simple).inject(self) do |hash, type|
        hash[type_name(type)] = type
        hash
      end
    end

    def type_name(type)
      type.name.is_a?(XSD::QName) ? type.name.name : type.name
    end

    def collect_types
      schemes = @definitions.importedschema.values << @definitions
      schemes.each do |schema|
        @complex += schema.collect_complextypes.to_a
        @simple += schema.collect_simpletypes.to_a
      end
    end

    def reorder
      @complex = sort_dependency(@complex)
    end

    def sort_dependency(types)
      dep = { }
      root = []
      types.each do |type|
        if type.complexcontent and (base = type.complexcontent.base)
          dep[base] ||= []
          dep[base] << type
        else
          root << type
        end
      end
      sorted = []
      root.each do |type|
        sorted.concat(collect_dependency(type, dep))
      end
      sorted.concat(dep.values.flatten)
      sorted.uniq
    end

    # removes collected key from dep
    def collect_dependency(type, dep)
      result = [type]
      return result unless dep.key?(type.name)
      dep[type.name].each do |deptype|
        result.concat(collect_dependency(deptype, dep))
      end
      dep.delete(type.name)
      result
    end
  end
end