require 'active_support/core_ext/string/inflections'

module DependencyInjection
  class Dependency
    attr_reader :klass_name, :arguments, :method_calls

    def initialize(klass_name)
      @arguments    = []
      @klass_name   = klass_name
      @method_calls = {}
    end

    def add_argument(argument)
      self.add_arguments(argument)
    end

    def add_arguments(*arguments)
      @arguments += arguments

      self
    end

    def add_method_call(method_name, *arguments)
      @method_calls[method_name] = arguments

      self
    end

    def klass
      self.klass_name.constantize
    end

    def object
      return @object if @object
      @object = self.klass.new(*self.arguments)
      self.method_calls.each { |method_name, arguments| @object.send(method_name, *arguments) }

      @object
    end
  end
end
