# dapr-rails

Rails engine to support [Dapr](https://dapr.io)

The code in this repo is a rough prototype to implement the Actor runtime.

## Usage

Add an initializer to your Rails application to register Actors:

```ruby
Dapr::Rails.configure do |config|
  config.app_id = "order-app"
  # Specify the class for actor types supported
  config.register_actor(:order, "OrderActor")
  # Subscribe to topics with a path to receive events
  config.subscribe("order-events", "/orders")
end
```

The Engine adds the following routes to support Dapr:

```
Routes for Dapr::Rails::Engine:
   config GET     /dapr/config(.:format)                                          dapr/rails/config#show {:format=>:json}
subscribe GET     /dapr/subscribe(.:format)                                       dapr/rails/topics#index {:format=>:json}
  healthz GET     /healthz(.:format)                                              dapr/rails/health#show {:format=>:json}
          PUT     /actors/:actor_type/:actor_id/method/remind/:reminder(.:format) dapr/rails/actors#remind {:format=>:json}
          PUT     /actors/:actor_type/:actor_id/method/timer/:timer(.:format)     dapr/rails/actors#timer {:format=>:json}
          PUT     /actors/:actor_type/:actor_id/method/:method(.:format)          dapr/rails/actors#invoke {:format=>:json}
          DELETE  /actors/:actor_type/:actor_id(.:format)                         dapr/rails/actors#delete {:format=>:json}
          OPTIONS /*path(.:format)                                                #<Proc> {:format=>:json}
```

### Actors

Subclass `Dapr::Rails::Actor` to implement an Actor class:

```ruby
class OrderActor < Dapr::Rails::Actor
  # Define methods for messages that the actor handles
  def submitted(data)
    ...
  end
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'dapr-rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install dapr-rails
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
