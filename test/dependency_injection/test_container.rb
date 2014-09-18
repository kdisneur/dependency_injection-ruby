require 'test_helper'
require 'dependency_injection/container'

class TestContainer < Minitest::Test
  def mock_definition(public=true)
    definition = mock

    definition.stubs(:public?).returns(public)

    definition
  end

  def setup
    @container     = DependencyInjection::Container.new
    @alias         = mock_definition
    @another_alias = mock_definition
    @final_object  = mock
    @definition    = mock_definition
    @definition.stubs(:object).returns(@final_object)
    @private_definition = mock_definition(false)
    @another_definition = mock_definition
    DependencyInjection::Definition.stubs(:new).with('MyDefinition', @container).returns(@definition)
    DependencyInjection::Definition.stubs(:new).with('MyOtherDefinition', @container).returns(@another_definition)
    DependencyInjection::Definition.stubs(:new).with('MyPrivateDefinition', @container).returns(@private_definition)
    DependencyInjection::AliasDefinition.stubs(:new).with('my_definition', @container).returns(@alias)
    DependencyInjection::AliasDefinition.stubs(:new).with('my_other_definition', @container).returns(@another_alias)
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

  def test_find_a_registered_definition_returns_a_definition
    @container.register('my_definition', 'MyDefinition')
    assert_equal(@definition, @container.find('my_definition'))
  end

  def test_find_a_not_registered_definition_returns_nil
    assert_equal(nil, @container.find('my_definition'))
  end

  def test_getting_a_registered_definition_returns_an_object
    @container.register('my_definition', 'MyDefinition')
    assert_equal(@final_object, @container.get('my_definition'))
  end

  def test_getting_a_not_registered_definition_returns_nil
    assert_equal(nil, @container.get('my_definition'))
  end

  def test_finding_a_private_definition_with_public_scope_returns_nil
    @container.register('my_definition', 'MyPrivateDefinition')

    assert_equal(nil, @container.find('my_definition'))
  end

  def test_finding_a_private_definition_with_private_scope_returns_definition
    @container.register('my_definition', 'MyPrivateDefinition')

    assert_equal(@private_definition, @container.find('my_definition', true))
  end

  def test_registering_a_definition
    @container.register('my_definition', 'MyDefinition')

    assert_equal({ 'my_definition' => @definition }, @container.definitions)
  end

  def test_registering_a_lazy_definition
    DependencyInjection::LazyDefinition.stubs(:new).with('MyLazyDefinition', @container)
    @container.register('my_lazy_definition', 'MyLazyDefinition', true)
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

  def test_registering_an_alias_returns_an_alias_definition_object
    assert_equal(@alias, @container.register_alias('my_alias', 'my_definition'))
  end

  def test_registering_an_already_existing_alias_definition_replace_it
    @container.register_alias('my_alias', 'my_definition')
    assert_equal({ 'my_alias' => @alias }, @container.definitions)

    @container.register_alias('my_alias', 'my_other_definition')
    assert_equal({ 'my_alias' => @another_alias }, @container.definitions)
  end
end
