# frozen_string_literal: true

module Dapr
  module Rails
    class BaseActor

      class << self
        def inherited(subclass)
          subclass.instance_variable_set(:@active_actors, Concurrent::Map.new)
        end

        def invoke(actor_type:, actor_id:, method:, data:)
          actor = active_actor(actor_type, actor_id)
          # TODO: check that actor responds to method?
          actor.public_send(method, data)
        end

        def active_actor(actor_type, actor_id)
          active_actors.fetch_or_store(actor_id) do |key|
            new(actor_type, key)
          end
        end

        private

        attr_reader :active_actors
      end

      def initialize(actor_type, actor_id)
        @actor_type = actor_type
        @actor_id = actor_id
      end
    end
  end
end