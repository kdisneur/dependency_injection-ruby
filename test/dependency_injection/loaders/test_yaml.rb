require 'test_helper'
require 'dependency_injection/loaders/yaml'

class TestYaml < Minitest::Test
  def setup
    @container   = mock
    @yaml_loader = DependencyInjection::Loaders::Yaml.new(@container)
  end

  def test_loading_file_without_parameters
    @yaml_loader.stubs(:load_file).with('services.yml').returns({ 'services' => [] })
    @yaml_loader.expects(:add_parameters).never

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_with_parameters
    @yaml_loader.stubs(:load_file).with('services.yml').returns({'parameters' => { 'key_1' => 'value_1' }, 'services' => [] })
    @yaml_loader.expects(:add_parameters).with({ 'key_1' => 'value_1' })

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_without_services
    @yaml_loader.stubs(:load_file).with('services.yml').returns({ 'parameters' => [] })
    @yaml_loader.expects(:add_services).never

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_with_services
    @yaml_loader.stubs(:load_file).with('services.yml').returns({ 'parameters' => {}, 'services' => { 'service_1' => { 'class' => 'MyKlass' }}})
    @yaml_loader.expects(:add_services).with({ 'service_1' => { 'class' => 'MyKlass' }})

    @yaml_loader.load('services.yml')
  end

  def test_adding_aliased_service
    @container.expects(:register_alias).with('my_alias', 'my_definition')

    @yaml_loader.send(:add_aliased_service, 'my_alias', 'my_definition')
  end

  def test_adding_parameters
    @container.expects(:add_parameter).with('key_1', 'value_1')
    @container.expects(:add_parameter).with('key_2', 'value_2')

    @yaml_loader.send(:add_parameters, { 'key_1' => 'value_1', 'key_2' => 'value_2' })
  end

  def test_adding_services
    @yaml_loader.expects(:add_service).with('key_1', { 'param_1' => 'value_1', 'param_2' => 'value_2' })
    @yaml_loader.expects(:add_service).with('key_2', { 'param_1' => 'value_1' })

    @yaml_loader.send(:add_services, { 'key_1' => { 'param_1' => 'value_1', 'param_2' => 'value_2' },
                                       'key_2' => { 'param_1' => 'value_1' }})
  end

  def test_adding_service_without_alias_parameters
    @yaml_loader.expects(:add_aliased_service).never
    @yaml_loader.expects(:add_standard_service).with('my_definition', { 'class' => 'MyKlass' })

    @yaml_loader.send(:add_service, 'my_definition', { 'class' => 'MyKlass' })
  end

  def test_adding_service_with_alias_parameters
    @yaml_loader.expects(:add_aliased_service).with('my_alias', 'my_definition')
    @yaml_loader.expects(:add_standard_service).never

    @yaml_loader.send(:add_service, 'my_alias', { 'alias' => 'my_definition' })
  end

  def test_adding_service_without_defined_scope
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)

    definition.expects(:scope=).never
    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_service_with_defined_scope
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)

    definition.expects(:scope=).with('awesome_scope')
    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass', 'scope' => 'awesome_scope' })
  end

  def test_adding_standard_service_as_lazy
    @container.expects(:register).with('my_lazy_definition', 'MyLazyDefinition', true)
    @yaml_loader.send(:add_standard_service, 'my_lazy_definition', { 'class' => 'MyLazyDefinition', 'lazy' => true })
  end

  def test_adding_standard_service_as_not_lazy
    @container.expects(:register).with('my_definition', 'MyDefinition', false)
    @yaml_loader.send(:add_standard_service, 'my_definition', { 'class' => 'MyDefinition', 'lazy' => false })
  end

  def test_adding_standard_service_with_default_lazy_value
    @container.expects(:register).with('my_definition', 'MyDefinition', false)
    @yaml_loader.send(:add_standard_service, 'my_definition', { 'class' => 'MyDefinition' })
  end

  def test_adding_standard_service_without_parameters
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_arguments).never

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_standard_service_with_parameters
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_arguments).with('arg_1', 'arg_2')

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass', 'arguments' => ['arg_1', 'arg_2'] })
  end

  def test_adding_standard_service_without_method_calls
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_method_call).never

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_standard_service_with_method_calls
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_method_call).with('method_1', 'arg_1')
    definition.expects(:add_method_call).with('method_2', 'arg_1', 'arg_2')
    definition.expects(:add_method_call).with('method_3', %w(arg_1 arg_2))

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass', 'calls' => { 'method_1' => ['arg_1'],
                                                                                  'method_2' => ['arg_1', 'arg_2'],
                                                                                  'method_3' => [['arg_1', 'arg_2']] }})
  end

  def test_adding_standard_service_without_configurator
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_configurator).never

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_standard_service_with_configurator
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:add_configurator).with('ConfiguratorKlass', 'method_name')

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass', 'configurator' => ['ConfiguratorKlass', 'method_name'] })
  end

  def test_adding_standard_service_with_file_path
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass', false).returns(definition)
    definition.expects(:file_path=).with('path/to/file')

    @yaml_loader.send(:add_standard_service, 'key_1', { 'class' => 'MyKlass', 'file_path' => 'path/to/file' })
  end
end
