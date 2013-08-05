require_relative '../test_helper'
require 'dependency_injection/container'

class TestContainer < Minitest::Test
  def setup
    @container    = DependencyInjection::Container.new
    @final_object = mock
    @definition   = mock
    @definition.stubs(:object).returns(@final_object)
    @another_definition = mock
    DependencyInjection::Definition.stubs(:new).with('MyDefinition', @container).returns(@definition)
    DependencyInjection::Definition.stubs(:new).with('MyOtherDefinition', @container).returns(@another_definition)
  end

  def test_adding_new_parameter
    @container.add_parameter('my.parameter', 'value')
    assert_equal({ 'my.parameter' => 'value' }, @container.parameters)
  end

  def test_adding_an_already_existing_parameter
    @container.add_parameter('my.parameter', 'value')
    assert_equal({ 'my.parameter' => 'value' }, @container.parameters)

    @container.add_parameter('my.parameter', 'other value')
    assert_equal({ 'my.parameter' => 'other value' }, @container.parameters)
  end

  def test_getting_a_registered_definition_returns_an_object
    @container.register('my_definition', 'MyDefinition')
    assert_equal(@final_object, @container.get('my_definition'))
  end

  def test_getting_a_not_registered_definition_returns_nil
    assert_equal(nil, @container.get('my_definition'))
  end

  def test_registering_a_definition
    @container.register('my_definition', 'MyDefinition')

    assert_equal({ 'my_definition' => @definition }, @container.definitions)
  end

  def test_registering_a_class_return_a_definition_object
    assert_equal(@definition, @container.register('my_definition', 'MyDefinition'))
  end

  def test_registering_an_already_existing_definition_replace_it
    @container.register('my_definition', 'MyDefinition')
    assert_equal({ 'my_definition' => @definition }, @container.definitions)

    @container.register('my_definition', 'MyOtherDefinition')
    assert_equal({ 'my_definition' => @another_definition }, @container.definitions)
  end
end
