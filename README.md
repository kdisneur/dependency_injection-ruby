# Dependency Injection for Ruby
[![Build Status](https://travis-ci.org/kdisneur/dependency_injection-ruby.png?branch=master)](https://travis-ci.org/kdisneur/dependency_injection-ruby) [![Coverage Status](https://coveralls.io/repos/kdisneur/dependency_injection-ruby/badge.png?branch=master)](https://coveralls.io/r/kdisneur/dependency_injection-ruby?branch=master) [![Code Climate](https://codeclimate.com/github/kdisneur/dependency_injection-ruby.png)](https://codeclimate.com/github/kdisneur/dependency_injection-ruby)

## Foreword

This gem is heavily inspired from The Symfony Framework [Container Service](http://symfony.com/doc/current/book/service_container.html). Here's the description they give to explain the concept:

> It helps you instantiate, organize and retrieve the many objects of your application. This object, called a service container, will allow you to standardize and centralize the way objects are constructed in your application. The container makes your life easier, is super fast, and emphasizes an architecture that promotes reusable and decoupled code.

You can learn more about everything this gem does by looking at the [examples](https://github.com/kdisneur/dependency_injection-ruby/tree/master/examples) directory. See [Usage](#usage) for a detailed explanation.

## Description

### Installation

Just add the gem to your Gemfile:

```ruby
gem 'dependency_injection'
```

Or simply install it using rubygems:

```shell
gem install dependency_injection
```

### Example

#### Without using Dependency Injection

In this example, we'll consider a simple application that needs to send emails for a newsletter.

We have the two following classes:

```ruby
# mailer.rb
class Mailer
  attr_accessor :transporter

  def initialize
    puts 'mailer initialized'
  end

  def send_mail(message, recipient)
    puts "mail sent via #{self.transporter}: #{message}"
  end
end
```

```ruby
# newsletter_manager.rb
class NewsletterManager
  def initialize(mailer)
    @mailer = mailer
  end

  def send_newsletter(message, recipients)
    puts 'newsletter #{message} send to #{recipients}'
    recipients.each { |recipient| @mailer.send_mail(message, recipient) }
  end
end
```

A `Mailer` class that handles email sending, through a given transporter, for a recipient.

A `NewsletterManager` class that sends a newsletter (message) to a list of recipients.

Without __DependencyInjection__, we would need to do the following to achieve our goal:

```ruby
# send_newsletter.rb
mailer = Mailer.new
mailer.transporter = :smtp

recipients = %w(john@doe.com david@heinemeier-hansson.com)
message    = 'I love dependency injection and think this is the future!'

newsletter_manager = NewsletterManager.new(mailer)
newsletter_manager.send_newsletter(message, recipients)
```

You have a working application but this code is thightly coupled and might be, in a real life, hard to refactor.

Another big drawback is that you have to instantiate as many objects as you have emails and newsletters to send.

#### Now with Dependency Injection

Our two classes stay untouched, the only thing you have to do is to add a configuration file.

```yaml
# services.yml
parameters:
  mailer.transporter: 'smtp'
services:
  mailer:
    class: 'Mailer'
    calls:
      - ['transporter=', '%mailer.transporter%']
  newsletter_manager:
    class: 'NewsletterManager'
    arguments:
      - '@mailer'
```

We now need to require __DependencyInjection__ and declare our __Container__.

Please note that the following code only needs to be declared once as long as the `container` value is accessible throughout your whole application.

```ruby
# initialize.rb
require 'dependency_injection/container'
require 'dependency_injection/loaders/yaml'

container = DependencyInjection::Container.new
loader    = DependencyInjection::Loaders::Yaml.new(container)
loader.load(File.join(File.dirname(File.expand_path(__FILE__)), 'services.yml'))
```

We can now do the same as the previous example with the following.

```ruby
# send_newsletter.rb
recipients = %w(john@doe.com david@heinemeier-hansson.com)
message    = 'I love dependency injection and think this is the future!'

container.get('newsletter_manager').send_newsletter(message, recipients)
```

Now your code is no longer tightly coupled and can be a lot more easily refactored. Moreover, the `Mailer` and `NewsletterManager` classes are only instantiated once during your application's lifecycle.

### Usage

Before diving into the details of __DependencyInjection__, here are some keywords that you need to be acquainted with:

* __Container__ object must be declared to be used by your application during it's whole lifecycle. The Container job is to register and retrieve Services.

* __Service__ is a Plain Old Ruby Object (Poro o/) that contains your own logic. The __DependencyInjection__ gem doesn't need to know anything about it and won't force your to add/inherit any specific method.

* __Configurator__ is a standard Ruby Class that shares a callable to be used by different objects (like Services) to configure them after their instantiation.

#### Configuration

__DependencyInjection__ needs to be configured, using a yaml file, in order to map your services with your existing classes and their dependencies. There's also some other options that we'll list below.

Here's a configuration file example using almost everything __DependencyInjection__ has to offer:

```yaml
parameters:
  mailer.transport: smtp
services:
  mailer:
    class: Mailer
    calls:
      - ['transport=', '%mailer.transport%']
    lazy: true
  newsletter:
    class: NewsletterManager
    arguments:
      - '@mailer'
```

And here's some more details about each keyword:

* `parameters`: Based on a basic key/value scheme. This can later be used throughout your services by calling `%parameter_name%`.

* `services`: The services name must be used as the first indentation tier.

* `class`: A string containing the class name of your service.

* `arguments`: An array containing the parameters used by your class `intialize` method.

* `calls`: An array containing an array of each instance method and its parameters. Note that you only need to define the methods during your class instantiation.

* `file_path`: A string containing the file path to require to load the class.

* `lazy`: Returns a Proxy Object if true. The _real_ object will only be instantiated at the first method call.

* `alias`: A string containing the target service name.

* `scope`: A string containing one of two possibles values to handle the service initialization scope:
  * `container`: a service is initialized only once throughout the container life (default)
  * `prototype`: a new service is initialized each time you call the container

  Note that the usage of a `prototype` service inside a `container` service raises a `ScopeWideningInjectionError`

__Please note:__
* You can reference a variable in the configuration with the following syntax: `%variable%`.
* You can reference declared services by prefixing it with an `@` sign.
* If you declare a service as an alias, the target service configuration will be used. Your own service configuration will be ignored.

### Tests

__DependencyInjection__ is covered by tests at 100%, see [coveralls.io](https://coveralls.io/r/kdisneur/dependency_injection-ruby) service.

If you want to launch the tests by yourself:
* Clone this repository by running `git clone git@github.com:kdisneur/dependency_injection-ruby`
* Run `bundle install`
* Run `rake test`

## Contribute

This is Github folks!

If you find a *bug*, open an [Issue](https://github.com/kdisneur/dependency_injection-ruby/issues).

It's OK to open an issue to ask us what we think about a change you'd like to make, so you don't work for nothing :)

If you want to add/change/hack/fix/improve/whatever something, make a [Pull Request](https://github.com/kdisneur/dependency_injection-ruby/pulls):

* Fork this repository
* Create a feature branch on your fork, we just love [git-flow](http://nvie.com/posts/a-successful-git-branching-model/)
* Do your stuff and pay attention to the following:
 * Your code should be documented using [Tomdoc](http://tomdoc.org)
 * You should follow [Github's Ruby Styleguide](https://github.com/styleguide/ruby)
 * If needed, squash your commits to group them logically
 * Update the CHANGELOG accordingly
* Make a Pull Request, we will *always* respond, and try to do it fast.
