require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

c = DependencyInjection::Container.new
loader = DependencyInjection::Loaders::Yaml.new(c)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'lazy_load_object.yml'))

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
  def initialize
    puts 'mailer loaded'
  end

  def send_mail(message)
    puts "mail sent via: #{message}"
  end
end

puts c.get('my.mailer').class
# => ProxyObject
puts c.get('my.newsletter_manager').class
# => NewsletterManager

c.get('my.newsletter_manager').send_mail('Hello World')
# => newsletter
#    mailer loaded
#    mail sent : Hello World
