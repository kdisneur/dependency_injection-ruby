require 'test_helper'
require 'dependency_injection/lazy_definition'

class TestLazyDefinition < Minitest::Test
  def setup
    @container       = mock
    @lazy_definition = DependencyInjection::LazyDefinition.new('MyKlass', @container)
  end

  def test_getting_object_returns_a_proxy_object
    assert_equal(DependencyInjection::ProxyObject, @lazy_definition.object.class)
  end
end
