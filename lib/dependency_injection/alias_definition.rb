module DependencyInjection
  class AliasDefinition
    attr_accessor :alias_definition_name

    def initialize(alias_definition_name, container)
      @container                 = container
      self.alias_definition_name = alias_definition_name
    end

    def object
      @container.get(self.alias_definition_name)
    end
  end
end
