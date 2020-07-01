# frozen_string_literal: true

module Dapr
  module Rails
    class ConfigController < Dapr::Rails::ApplicationController
      def show
        render json: {
          entities: Dapr::Rails.actor_registry.keys,
          actorIdleTimeout: Dapr::Rails.actor_idle_timeout,
          actorScanInterval: Dapr::Rails.actor_scan_interval,
          drainOngoingCallTimeout: Dapr::Rails.drain_ongoing_call_timeout,
          drainRebalancedActors: Dapr::Rails.drain_rebalanced_actors,
        }
      end
    end
  end
end