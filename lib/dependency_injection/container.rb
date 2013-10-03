require 'dependency_injection/alias_definition'
require 'dependency_injection/definition'
require 'dependency_injection/lazy_definition'

module DependencyInjection
  class Container
    attr_reader :definitions, :parameters

    def initialize
      @definitions = {}
      @parameters  = {}
    end

    def add_parameter(name, value)
      @parameters[name] = value
    end

    def find(name)
      @definitions[name]
    end

    def get(name)
      if (definition = self.find(name))
        definition.object
      end
    end

    def register(name, klass_name, lazy=false)
      definition = lazy ? LazyDefinition.new(klass_name, self) : Definition.new(klass_name, self)
      @definitions[name] = definition
    end

    def register_alias(name, alias_definition_name)
      @definitions[name] = AliasDefinition.new(alias_definition_name, self)
    end
  end
end
