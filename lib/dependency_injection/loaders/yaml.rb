require 'erb'
require 'yaml'

module DependencyInjection
  module Loaders
    class Yaml
      def initialize(container)
        @container = container
      end

      def load(filename)
        file = load_file(filename)
        add_parameters(file['parameters']) if file['parameters']
        add_services(file['services']) if file['services']
      end

    private

      def add_aliased_service(name, aliased_service_name)
        @container.register_alias(name, aliased_service_name)
      end

      def add_parameters(parameters)
        parameters.each { |name, value| @container.add_parameter(name, value) }
      end

      def add_services(services)
        services.each { |name, parameters| add_service(name, parameters) }
      end

      def add_service(name, parameters)
        if parameters['alias']
          add_aliased_service(name, parameters['alias'])
        else
          add_standard_service(name, parameters)
        end
      end

      def add_standard_service(name, parameters)
        lazy_load  = parameters['lazy'] || false
        definition = @container.register(name, parameters['class'], lazy_load)
        definition.scope = parameters['scope'] if parameters['scope']
        definition.add_arguments(*parameters['arguments']) if parameters['arguments']
        if (configurator = parameters['configurator'])
          definition.add_configurator(configurator[0], configurator[1])
        end
        if parameters['calls']
          parameters['calls'].each { |method_name, arguments| definition.add_method_call(method_name, *arguments) }
        end
      end

      def load_file(filename)
        YAML::load(ERB.new(IO.read(filename)).result)
      end
    end
  end
end
