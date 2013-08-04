require 'dependency_injection/container'

c = DependencyInjection::Container.new

# 1 - No specific class initialization
class Mailer
  def send_mail(message)
    puts "mail sent: #{message}"
  end
end

c.register('mailer', 'Mailer')
c.get('mailer').send_mail('Hello World')
# => mail sent: Hello World

Object.instance_eval { remove_const(:Mailer) }

# 2 - constructor specific class initialization
class Mailer
  def initialize(transport)
    @transport = transport
  end

  def send_mail(message)
    puts "mail sent via #{@transport}: #{message}"
  end
end

c.register('mailer', 'Mailer').add_argument('send_mail')
c.get('mailer').send_mail('Hello World')
# => mail sent via send_mail: Hello World

Object.instance_eval { remove_const(:Mailer) }

# 3 - method specific class initialization
class Mailer
  attr_accessor :transport

  def send_mail(message)
    puts "mail sent via #{self.transport}: #{message}"
  end
end

c.register('mailer', 'Mailer').add_method_call('transport=', 'send_mail')
c.get('mailer').send_mail('Hello World')
# => mail sent via send_mail: Hello World

# 4 - Mix of constructor and method specific class initialization
class Mailer
  attr_accessor :transport

  def initialize(from)
    @from = from
  end

  def send_mail(message)
    puts "mail sent by #{@from} via #{self.transport}: #{message}"
  end
end

c.register('mailer', 'Mailer').add_argument('jon@doe.com').add_method_call('transport=', 'send_mail')
c.get('mailer').send_mail('Hello World')
# => mail sent by jon@doe.com via send_mail: Hello World

