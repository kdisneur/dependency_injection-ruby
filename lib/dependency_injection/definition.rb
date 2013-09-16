require 'active_support/core_ext/string/inflections'
require 'dependency_injection/scope_widening_injection_error'

module DependencyInjection
  class Definition
    attr_accessor :arguments, :configurator, :klass_name, :method_calls, :scope

    def initialize(klass_name, container)
      @container        = container
      self.arguments    = []
      self.klass_name   = klass_name
      self.method_calls = {}
      self.scope        = :container
    end

    def add_argument(argument)
      self.add_arguments(argument)
    end

    def add_arguments(*arguments)
      self.arguments += arguments

      self
    end

    def add_configurator(name, method_name)
      self.configurator = [name, method_name]

      self
    end

    def add_method_call(method_name, *arguments)
      self.method_calls[method_name] = arguments

      self
    end

    def klass
      self.klass_name.constantize
    end

    def object
      self.send("#{self.scope}_scoped_object")
    end

  private

    def container_scoped_object
      @object ||= initialize_object
    end

    def initialize_object
      object = self.klass.new(*resolve(self.arguments))
      self.method_calls.each { |method_name, arguments| object.send(method_name, *resolve(arguments)) }
      if self.configurator
        name, method_name   = self.configurator
        configurator_object = resolve([name]).first
        configurator_object.send(method_name, object)
      end

      object
    end

    def prototype_scoped_object
      initialize_object
    end

    def resolve(arguments)
      resolve_references(resolve_container_parameters(arguments))
    end

    def resolve_container_parameters(arguments)
      arguments.map do |argument|
        if /^%(?<parameter_name>.*)%$/ =~ argument
          @container.parameters[parameter_name]
        else
          argument
        end
      end
    end

    def resolve_references(arguments)
      arguments.map do |argument|
        if /^@(?<reference_name>.*)/ =~ argument
          reference = @container.get(reference_name)
          raise ScopeWideningInjectionError if reference.scope == :prototype && scope == :container

          reference
        else
          argument
        end
      end
    end
  end
end
