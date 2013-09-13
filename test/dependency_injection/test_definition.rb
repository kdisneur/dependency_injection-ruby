require 'test_helper'
require 'dependency_injection/definition'

class TestDefinition < Minitest::Test
  def setup
    @container  = mock
    @definition = DependencyInjection::Definition.new('MyClass', @container)
  end

  def test_adding_an_argument
    @definition.add_argument('new argument')

    assert_equal(['new argument'], @definition.arguments)
  end

  def test_adding_an_argument_returns_definition_object
    assert_equal(@definition, @definition.add_argument('new argument'))
  end

  def test_adding_several_arguments
    @definition.add_arguments('first', 'second')

    assert_equal(%w(first second), @definition.arguments)
  end

  def test_adding_several_arguments_returns_definition_object
    assert_equal(@definition, @definition.add_arguments('first', 'second'))
  end

  def test_adding_additional_arguments
    @definition.add_arguments('first')
    assert_equal(%w(first), @definition.arguments)

    @definition.add_arguments('second', 'third')
    assert_equal(%w(first second third), @definition.arguments)
  end

  def test_adding_configurator
    @definition.add_configurator('ConfiguratorKlass', 'method_name')

    assert_equal(%w(ConfiguratorKlass method_name), @definition.configurator)
  end

  def test_adding_configurator_returns_definition_object
    assert_equal(@definition, @definition.add_configurator('ConfiguratorKlass', 'method_name'))
  end

  def test_adding_a_method_call_without_parameters
    @definition.add_method_call('my_method')

    assert_equal({ 'my_method' => [] }, @definition.method_calls)
  end

  def test_adding_a_method_call_with_parameters
    @definition.add_method_call('my_method=', 'value')

    assert_equal({ 'my_method=' => %w(value) }, @definition.method_calls)
  end

  def test_adding_a_method_call_returns_definition_object
    assert_equal(@definition, @definition.add_method_call('my_method'))
  end

  def test_getting_klass
    klass      = mock
    klass_name = 'MyClass'
    @definition.stubs(:klass_name).returns(klass_name)
    klass_name.stubs(:constantize).returns(klass)

    assert_equal(klass, @definition.klass)
  end

  def test_getting_object_with_arguments
    final_object = mock
    final_class  = mock
    @definition.stubs(:klass).returns(final_class)
    @definition.add_arguments('first', 'second')
    final_class.stubs(:new).with('first', 'second').returns(final_object)

    assert_equal(final_object, @definition.object)
  end

  def test_getting_object_without_arguments
    final_object = mock
    final_class  = mock
    @definition.stubs(:klass).returns(final_class)
    final_class.stubs(:new).with.returns(final_object)

    assert_equal(final_object, @definition.object)
  end

  def test_getting_object_with_method_calls
    final_object = mock
    final_class  = mock
    @definition.stubs(:klass).returns(final_class)
    final_class.stubs(:new).with.returns(final_object)
    final_object.expects(:method_1).with
    final_object.expects(:method_2).with('value')

    @definition.add_method_call('method_1')
    @definition.add_method_call('method_2', 'value')

    @definition.object
  end

  def test_getting_object_without_configurator
    configurator_object = mock
    final_object        = mock
    final_class         = mock
    @definition.stubs(:klass).returns(final_class)
    @definition.stubs(:resolve).with([]).returns([])
    @definition.stubs(:resolve).with(['ConfiguratorKlass']).returns([configurator_object])
    configurator_object.expects(:send).never
    final_class.stubs(:new).with.returns(final_object)

    @definition.object
  end

  def test_getting_object_with_configurator
    configurator_object = mock
    final_object        = mock
    final_class         = mock
    @definition.stubs(:klass).returns(final_class)
    @definition.stubs(:resolve).with([]).returns([])
    @definition.stubs(:resolve).with(['ConfiguratorKlass']).returns([configurator_object])
    @definition.add_configurator('ConfiguratorKlass', 'method_name')
    configurator_object.expects(:send).with('method_name', final_object)
    final_class.stubs(:new).with.returns(final_object)

    @definition.object
  end

  def test_getting_container_scoped_object
    @definition.scope = :container
    @definition.expects(:send).with('container_scoped_object')
    @definition.object
  end

  def test_getting_container_scoped_object_multiple_times
    @definition.stubs(:initialize_object).returns(:object_1, :object_2)
    @definition.scope = :container
    assert_equal(:object_1, @definition.object)
    assert_equal(:object_1, @definition.object)
  end

  def test_getting_prototype_scoped_object
    @definition.scope = :prototype
    @definition.expects(:send).with('prototype_scoped_object')
    @definition.object
  end

  def test_getting_prototype_scoped_object_multiple_times
    @definition.stubs(:initialize_object).returns(:object_1, :object_2)
    @definition.scope = :prototype
    assert_equal(:object_1, @definition.object)
    assert_equal(:object_2, @definition.object)
  end

  def test_resolving_first_container_parameters
    changed_arguments = mock
    arguments         = mock
    @definition.stubs(:resolve_references).returns(changed_arguments)
    @definition.expects(:resolve_container_parameters).with(arguments)

    @definition.send(:resolve, arguments)
  end

  def test_resolving_references_after_container_parameters
    changed_arguments = mock
    arguments         = mock
    @definition.stubs(:resolve_container_parameters).with(arguments).returns(changed_arguments)
    @definition.expects(:resolve_references).with(changed_arguments)

    @definition.send(:resolve, arguments)
  end

  def test_resolving_container_parameters_without_parameters
    assert_equal(%w(first, second), @definition.send(:resolve_container_parameters, %w(first, second)))
  end

  def test_resolving_container_parameters_with_parameters
    @container.stubs(:parameters).returns({ 'parameter' => 'value' })

    assert_equal(['first', 'value'], @definition.send(:resolve_container_parameters, %w(first %parameter%)))
  end

  def test_resolving_references_without_references
    assert_equal(%w(first second), @definition.send(:resolve_references, %w(first second)))
  end

  def test_resolving_references_with_defintion_and_referenced_object_in_container_scope
    referenced_object = mock
    referenced_object.stubs(:scope).returns(:container)
    @definition.scope= :container
    @container.stubs(:get).with('reference.name').returns(referenced_object)

    assert_equal(['first', referenced_object], @definition.send(:resolve_references, %w(first @reference.name)))
  end

  def test_resolving_references_with_defintion_and_referenced_object_in_prototype_scope
    referenced_object = mock
    referenced_object.stubs(:scope).returns(:prototype)
    @definition.scope= :prototype
    @container.stubs(:get).with('reference.name').returns(referenced_object)

    assert_equal(['first', referenced_object], @definition.send(:resolve_references, %w(first @reference.name)))
  end

  def test_resolving_references_with_defintion_in_prototype_scope_and_referenced_object_in_container_scope
    referenced_object = mock
    referenced_object.stubs(:scope).returns(:container)
    @definition.scope= :prototype
    @container.stubs(:get).with('reference.name').returns(referenced_object)

    assert_equal(['first', referenced_object], @definition.send(:resolve_references, %w(first @reference.name)))
  end

  def test_resolving_references_with_defintion_in_container_scope_and_referenced_object_in_prototype_scope
    referenced_object = mock
    referenced_object.stubs(:scope).returns(:prototype)
    @definition.scope= :container
    @container.stubs(:get).with('reference.name').returns(referenced_object)

    assert_raises(ScopeWideningInjectionError) { @definition.send(:resolve_references, %w(first @reference.name)) }
  end
end
