require 'test_helper'
require 'dependency_injection/loaders/yaml'

class TestYaml < Minitest::Test
  def setup
    @container   = mock
    @yaml_loader = DependencyInjection::Loaders::Yaml.new(@container)
  end

  def test_loading_file_without_parameters
    YAML.stubs(:load_file).with('services.yml').returns({ 'services' => [] })
    @yaml_loader.expects(:add_parameters).never

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_with_parameters
    YAML.stubs(:load_file).with('services.yml').returns({'parameters' => { 'key_1' => 'value_1' }, 'services' => [] })
    @yaml_loader.expects(:add_parameters).with({ 'key_1' => 'value_1' })

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_without_services
    YAML.stubs(:load_file).with('services.yml').returns({ 'parameters' => [] })
    @yaml_loader.expects(:add_services).never

    @yaml_loader.load('services.yml')
  end

  def test_loading_file_with_services
    YAML.stubs(:load_file).with('services.yml').returns({ 'parameters' => {}, 'services' => { 'service_1' => { 'class' => 'MyKlass' }}})
    @yaml_loader.expects(:add_services).with({ 'service_1' => { 'class' => 'MyKlass' }})

    @yaml_loader.load('services.yml')
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

  def test_adding_service_without_parameters
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass').returns(definition)
    definition.expects(:add_arguments).never

    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_service_with_parameters
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass').returns(definition)
    definition.expects(:add_arguments).with('arg_1', 'arg_2')

    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass', 'arguments' => ['arg_1', 'arg_2'] })
  end

  def test_adding_service_without_method_calls
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass').returns(definition)
    definition.expects(:add_method_call).never

    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass' })
  end

  def test_adding_service_with_method_calls
    definition = mock
    @container.stubs(:register).with('key_1', 'MyKlass').returns(definition)
    definition.expects(:add_method_call).with('method_1', 'arg_1')
    definition.expects(:add_method_call).with('method_2', 'arg_1', 'arg_2')
    definition.expects(:add_method_call).with('method_3', %w(arg_1 arg_2))

    @yaml_loader.send(:add_service, 'key_1', { 'class' => 'MyKlass', 'calls' => { 'method_1' => ['arg_1'],
                                                                                  'method_2' => ['arg_1', 'arg_2'],
                                                                                  'method_3' => [['arg_1', 'arg_2']] }})
  end
end
