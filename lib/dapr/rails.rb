require "dapr/rails/engine"

module Dapr
  module Rails
    mattr_accessor :dapr_url, default: "http://localhost:3500"
    mattr_accessor :app_id
    mattr_accessor :actor_idle_timeout, default: "10s" # TODO
    mattr_accessor :actor_scan_interval, default: "10s"
    mattr_accessor :drain_ongoing_call_timeout, default: "30s"
    mattr_accessor :drain_rebalanced_actors, default: true

    mattr_reader :actor_registry
    mattr_reader :topics

    @@actor_registry = Hash.new
    @@topics = Array.new
    @@actor_class_map = Concurrent::Map.new

    class << self
      def configure
        yield self
      end

      def register_actor(actor_type, class_name)
        actor_registry[actor_type.to_s] = class_name
      end

      def subscribe(topic, path)
        topics << { topic: topic, route: path }
      end

      def actor_class(actor_type)
        @@actor_class_map.fetch_or_store(actor_type) do |key|
          actor_registry[key].constantize
        end
      end
    end
  end
end
