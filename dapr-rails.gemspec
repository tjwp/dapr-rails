$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "dapr/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "dapr-rails"
  spec.version     = Dapr::Rails::VERSION
  spec.authors     = ["Tim Perkins"]
  spec.email       = ["tim.perkins@ezcater.com"]
  spec.homepage    = "https://github.com/tjwp/dapr-rails"
  spec.summary     = "Rails engine to support a Dapr API"
  spec.description = "Rails Engine to support a Dapr API"
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "dapr-client", ">= 0.2.0"
  spec.add_dependency "rails", "~> 6.0.3", ">= 6.0.3.2"

  spec.add_runtime_dependency "faraday" # used by actors
end
