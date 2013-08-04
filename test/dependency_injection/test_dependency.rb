require_relative '../test_helper'
require 'dependency_injection/dependency'

class TestDependency < Minitest::Test
  def setup
    @dependency = DependencyInjection::Dependency.new('MyClass')
  end

  def test_adding_an_argument
    @dependency.add_argument('new argument')

    assert_equal(['new argument'], @dependency.arguments)
  end

  def test_adding_an_argument_returns_dependency_object
    assert_equal(@dependency, @dependency.add_argument('new argument'))
  end

  def test_adding_several_arguments
    @dependency.add_arguments('first', 'second')

    assert_equal(%w(first second), @dependency.arguments)
  end

  def test_adding_several_arguments_returns_dependency_object
    assert_equal(@dependency, @dependency.add_arguments('first', 'second'))
  end

  def test_adding_additional_arguments
    @dependency.add_arguments('first')
    assert_equal(%w(first), @dependency.arguments)

    @dependency.add_arguments('second', 'third')
    assert_equal(%w(first second third), @dependency.arguments)
  end

  def test_adding_a_method_call_without_parameters
    @dependency.add_method_call('my_method')

    assert_equal({ 'my_method' => [] }, @dependency.method_calls)
  end

  def test_adding_a_method_call_with_parameters
    @dependency.add_method_call('my_method=', 'value')

    assert_equal({ 'my_method=' => %w(value) }, @dependency.method_calls)
  end

  def test_adding_a_method_call_returns_dependency_object
    assert_equal(@dependency, @dependency.add_method_call('my_method'))
  end

  def test_getting_klass
    klass      = mock
    klass_name = 'MyClass'
    @dependency.stubs(:klass_name).returns(klass_name)
    klass_name.stubs(:constantize).returns(klass)

    assert_equal(klass, @dependency.klass)
  end

  def test_getting_object_with_arguments
    final_object = mock
    final_class  = mock
    @dependency.stubs(:klass).returns(final_class)
    @dependency.add_arguments('first', 'second')
    final_class.stubs(:new).with('first', 'second').returns(final_object)

    assert_equal(final_object, @dependency.object)
  end

  def test_getting_object_without_arguments
    final_object = mock
    final_class  = mock
    @dependency.stubs(:klass).returns(final_class)
    final_class.stubs(:new).with.returns(final_object)

    assert_equal(final_object, @dependency.object)
  end

  def test_getting_object_with_method_calls
    final_object = mock
    final_class  = mock
    @dependency.stubs(:klass).returns(final_class)
    final_class.stubs(:new).with.returns(final_object)
    final_object.expects(:method_1).with
    final_object.expects(:method_2).with('value')

    @dependency.add_method_call('method_1')
    @dependency.add_method_call('method_2', 'value')

    @dependency.object
  end
end
