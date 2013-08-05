require 'dependency_injection/dependency'

module DependencyInjection
  class Container
    attr_reader :dependencies, :parameters

    def initialize
      @dependencies = {}
      @parameters   = {}
    end

    def add_parameter(name, value)
      @parameters[name] = value
    end

    def get(name)
      if (dependency = @dependencies[name])
        dependency.object
      end
    end

    def register(name, klass_name)
      @dependencies[name] = Dependency.new(klass_name, self)
    end
  end
end
