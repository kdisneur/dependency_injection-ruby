require 'test_helper'
require 'dependency_injection/alias_definition'

class TestAliasDefinition < Minitest::Test
  def setup
    @container        = mock
    @alias_definition = DependencyInjection::AliasDefinition.new('my_definition', @container)
  end

  def test_getting_object_to_container
    @container.expects(:get).with('my_definition')

    @alias_definition.object
  end
end
