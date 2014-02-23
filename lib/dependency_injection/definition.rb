require 'active_support/core_ext/string/inflections'
require 'dependency_injection/scope_widening_injection_error'

module DependencyInjection
  class Definition
    attr_accessor :arguments, :configurator, :file_path, :klass_name, :method_calls, :scope

    def initialize(klass_name, container)
      @container        = container
      self.arguments    = []
      self.file_path    = nil
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
      require_object
      object = self.klass.new(*resolve(self.arguments))
      self.method_calls.each { |method_name, arguments| object.send(method_name, *resolve(arguments)) }
      if self.configurator
        name, method_name   = self.configurator
        configurator_object = resolve([name]).first
        configurator_object.send(method_name, object)
      end

      object
    end

    def object_already_required?
      true if Kernel.const_get(self.klass_name)
    rescue
      false
    end

    def prototype_scoped_object
      initialize_object
    end

    def require_object
      return if object_already_required?

      if self.file_path
        require self.file_path
      else
        require self.klass_name.underscore
      end
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
          reference_definition = @container.find(reference_name)
          reference            = reference_definition.object
          raise ScopeWideningInjectionError if reference_definition.scope == :prototype && scope == :container

          reference
        else
          argument
        end
      end
    end
  end
end
