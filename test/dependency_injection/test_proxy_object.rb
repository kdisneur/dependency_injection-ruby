require 'test_helper'
require 'dependency_injection/proxy_object'

class TestProxyObject < Minitest::Test
  def setup
    @object       = mock
    @proxy_object = DependencyInjection::ProxyObject.new { @object }
  end

  def test_calling_a_method_existing_on_object
    @object.expects(:existing_method).with('arg_1', 'arg_2')

    @proxy_object.existing_method('arg_1', 'arg_2')
  end
end
