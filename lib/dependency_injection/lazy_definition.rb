require 'dependency_injection/definition'
require 'dependency_injection/proxy_object'

module DependencyInjection
  class LazyDefinition < Definition
    def object
      return @proxy_object if @proxy_object

      @proxy_object = ProxyObject.new { super }
    end
  end
end
