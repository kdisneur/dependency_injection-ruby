require 'dependency_injection/dependency'

module DependencyInjection
  class Container
    attr_reader :dependencies

    def initialize
      @dependencies = {}
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
