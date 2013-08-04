require_relative '../test_helper'
require 'dependency_injection/container'

class TestContainer < Minitest::Test
  def setup
    @container          = DependencyInjection::Container.new
    @final_object       = mock
    @dependency_object  = mock
    @dependency_object.stubs(:object).returns(@final_object)
    @another_dependency_object = mock
    DependencyInjection::Dependency.stubs(:new).with('MyDependency').returns(@dependency_object)
    DependencyInjection::Dependency.stubs(:new).with('MyOtherDependency').returns(@another_dependency_object)
  end

  def test_getting_a_registered_dependency_returns_an_object
    @container.register('my_dependency', 'MyDependency')
    assert_equal(@final_object, @container.get('my_dependency'))
  end

  def test_getting_a_not_registered_dependency_returns_nil
    assert_equal(nil, @container.get('my_dependency'))
  end

  def test_registering_a_dependency
    @container.register('my_dependency', 'MyDependency')

    assert_equal({ 'my_dependency' => @dependency_object }, @container.dependencies)
  end

  def test_registering_a_class_return_a_dependency_object
    assert_equal(@dependency_object, @container.register('my_dependency', 'MyDependency'))
  end

  def test_registering_an_already_existing_dependency_replace_it
    @container.register('my_dependency', 'MyDependency')
    assert_equal({ 'my_dependency' => @dependency_object }, @container.dependencies)

    @container.register('my_dependency', 'MyOtherDependency')
    assert_equal({ 'my_dependency' => @another_dependency_object }, @container.dependencies)
  end
end
