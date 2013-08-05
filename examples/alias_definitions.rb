require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

c = DependencyInjection::Container.new
loader = DependencyInjection::Loaders::Yaml.new(c)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'alias_definitions.yml'))

class Mailer
  attr_accessor :transport

  def send_mail(message)
    puts "mail sent via #{self.transport}: #{message}"
  end
end

puts c.get('my.mailer').class
# => Mailer
puts c.get('aliased.mailer').class
# => Mailer
