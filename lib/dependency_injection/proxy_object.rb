module DependencyInjection
  class ProxyObject
    def initialize(&block)
      @object = block
    end

    def method_missing(method_name, *args)
      @object.call.send(method_name, *args)
    end
  end
end
