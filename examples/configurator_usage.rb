require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

c = DependencyInjection::Container.new
loader = DependencyInjection::Loaders::Yaml.new(c)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'configurator_usage.yml'))

class MailerConfigurator
  def initialize(transport)
    @transport = transport
  end

  def configure(mailer)
    mailer.transport = @transport
  end
end

class Mailer
  attr_accessor :transport

  def send_mail(message)
    puts "mail sent via #{self.transport}: #{message}"
  end
end

c.get('my.mailer').send_mail('Hello World')
#    mail sent via sendmail: Hello World
