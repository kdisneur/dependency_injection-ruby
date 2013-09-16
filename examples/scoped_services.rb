require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

c = DependencyInjection::Container.new
loader = DependencyInjection::Loaders::Yaml.new(c)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'scoped_services.yml'))

class ContainerScopedService
  def initialize
    puts 'Container scoped initialization'
  end
end

class PrototypeScopedService
  def initialize
    puts 'Prorotype scoped initialization'
  end
end

c.get('my.container.scoped.service')
# => Container scoped initialization
c.get('my.container.scoped.service')
# =>

c.get('my.prototype.scoped.service')
# => Prorotype scoped initialization
c.get('my.prototype.scoped.service')
# => Prorotype scoped initialization
