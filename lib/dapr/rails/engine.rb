module Dapr
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Dapr::Rails
      engine_name :dapr
      config.generators.api_only = true
    end
  end
end
