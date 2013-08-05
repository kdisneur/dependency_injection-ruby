require 'yaml'

module DependencyInjection
  module Loaders
    class Yaml
      def initialize(container)
        @container = container
      end

      def load(filename)
        file = YAML::load_file(filename)
        add_parameters(file['parameters']) if file['parameters']
        add_services(file['services']) if file['services']
      end

    private

      def add_parameters(parameters)
        parameters.each { |name, value| @container.add_parameter(name, value) }
      end

      def add_services(services)
        services.each { |name, parameters| add_service(name, parameters) }
      end

      def add_service(name, parameters)
        definition = @container.register(name, parameters['class'])
        definition.add_arguments(*parameters['arguments']) if parameters['arguments']
        if parameters['calls']
          parameters['calls'].each { |method_name, arguments| definition.add_method_call(method_name, *arguments) }
        end
      end
    end
  end
end
