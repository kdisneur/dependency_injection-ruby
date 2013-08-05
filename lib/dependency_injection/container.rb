require 'dependency_injection/alias_definition'
require 'dependency_injection/definition'

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

    def get(name)
      if (definition = @definitions[name])
        definition.object
      end
    end

    def register(name, klass_name)
      @definitions[name] = Definition.new(klass_name, self)
    end

    def register_alias(name, alias_definition_name)
      @definitions[name] = AliasDefinition.new(alias_definition_name, self)
    end
  end
end
