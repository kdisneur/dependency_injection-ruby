require 'dependency_injection/container'

c = DependencyInjection::Container.new

# 1 - constructor specific class initialization
class NewsletterManager
  def initialize(mailer)
    @mailer = mailer
  end

  def send_mail(message)
    @mailer.send_mail(message)
  end
end

class Mailer
  def send_mail(message)
    puts "mail sent: #{message}"
  end
end

c.register('my.mailer', 'Mailer')
c.register('newsletter', 'NewsletterManager').add_argument('@my.mailer')

c.get('newsletter').send_mail('Hello World')
# => mail sent: Hello World

Object.instance_eval { remove_const(:NewsletterManager) }

# 2 - method specific class initialization
class NewsletterManager
  attr_accessor :mailer, :from

  def send_mail(message)
    puts "mail sent by #{@from}"
    @mailer.send_mail(message)
  end
end

c.register('my.mailer', 'Mailer')
c.register('newsletter', 'NewsletterManager')
  .add_method_call('mailer=', '@my.mailer')
  .add_method_call('from=', 'john@doe.com')

c.get('newsletter').send_mail('Hello World')
# => mail sent: Hello World

Object.instance_eval { remove_const(:Mailer) }
