require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

c = DependencyInjection::Container.new
loader = DependencyInjection::Loaders::Yaml.new(c)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'services.yml'))

class NewsletterManager
  def initialize(mailer)
    @mailer = mailer
  end

  def send_mail(message)
    puts 'newletter'
    @mailer.send_mail(message)
  end
end

class Mailer
  attr_accessor :transport

  def send_mail(message)
    puts "mail sent via #{self.transport}: #{message}"
  end
end

c.get('newsletter').send_mail('Hello World')
# => newletter
#    mail sent via sendmail: Hello World
