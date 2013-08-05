require 'dependency_injection/container'

c = DependencyInjection::Container.new
c.add_parameter('mailer.transport', 'sendmail')

class Mailer
  attr_accessor :transport

  def send_mail(message)
    puts "mail sent via #{transport}: #{message}"
  end
end

# 1 - Simple global parameter
c.register('mailer', 'Mailer').add_method_call('transport=', '%mailer.transport%')
c.get('mailer').send_mail('Hello World')
# => mail sent via send_mail: Hello World

# 2 - Complex global parameter
class NewsletterManager
  def initialize(mailer)
    @mailer = mailer
  end

  def send_mail(message)
    puts 'newsletter'
    @mailer.send_mail(message)
  end
end

c.add_parameter('my.mailer', '@mailer')
c.register('newsletter', 'NewsletterManager').add_argument('%my.mailer%')
c.get('newsletter').send_mail('Hello World')
# => newsletter
#    mail sent via send_mail: Hello World
