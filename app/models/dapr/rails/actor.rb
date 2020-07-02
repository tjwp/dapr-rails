# frozen_string_literal: true

require "faraday"
require "dapr-client"

module Dapr
  module Rails
    class Actor
      include Concurrent::Async

      STATE_STORE = "statestore" # TODO: configurable?, by actor?

      class << self
        def inherited(subclass)
          subclass.instance_variable_set(:@active_actors, Concurrent::Map.new)
        end

        def invoke(actor_type:, actor_id:, method:, data:)
          actor = activate_actor(actor_type, actor_id)
          ::Rails.logger.info("ACTIVATED actor #{actor_type} #{actor_id}")
          actor.await.fetch_state
          # TODO: check that actor responds to method?
          result = actor.await.public_send(method, data)
          actor.await.save_state
          ::Rails.logger.info("INVOKED method #{method} for #{actor_type} #{actor_id}")
          result
        end

        def invoke_timer(actor_type:, actor_id:, timer:)
          actor = activate_actor(actor_type, actor_id)
          actor.await.fetch_state
          actor.await.public_send(timer)
          ::Rails.logger.info("INVOKED timer #{timer} for #{actor_type} #{actor_id}")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end

        def invoke_reminder(actor_type:, actor_id:, reminder:)
          actor = activate_actor(actor_type, actor_id)
          actor.await.fetch_state
          actor.await.public_send(reminder)
          ::Rails.logger.info("INVOKED reminder #{reminder} for #{actor_type} #{actor_id}")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end

        def deactivate_actor(actor_id)
          ::Rails.logger.info("Deactivating actor #{actor_id}")
          actor = active_actors[actor_id]
          actor.await.deactivate if actor.present?
          { actor_id: actor_id } if actor.present?
        end

        # Called by actor to remove itself
        def remove_actor(actor)
          active_actors.delete(actor.actor_id)
        end

        private

        attr_reader :active_actors

        def activate_actor(actor_type, actor_id)
          active_actors.fetch_or_store(actor_id) do |key|
            ::Rails.logger.info("ACTIVATING actor #{actor_type} #{key}")
            new(actor_type, key)
          end
        end
      end

      def initialize(actor_type, actor_id)
        super()
        @actor_type = actor_type
        @actor_id = actor_id
        @client = Dapr::Client::GRPC.new
        @store = client.state_store(STATE_STORE)
      end


      def message_me(method, data = nil)
        Thread.new do
          ::Rails.logger.info("Sending message #{method} to #{actor_type} #{actor_id}")
          Faraday.post("#{Dapr::Rails.dapr_url}/v1.0/actors/#{actor_type}/#{actor_id}/method/#{method}",
                       data.to_json, "Content-Type" => "application/json")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end
      end

      # TODO: durations for inputs?
      def add_reminder(reminder, due_time, period)
        Thread.new do
          data = {
            dueTime: "0h0m#{due_time}s0ms",
            period: "0h0m#{period}s0ms"
          }
          ::Rails.logger.info("Setting reminder #{reminder} for #{actor_type} #{actor_id}")
          Faraday.post("#{Dapr::Rails.dapr_url}/v1.0/actors/#{actor_type}/#{actor_id}/reminders/#{reminder}",
                       data.to_json, "Content-Type" => "application/json")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end
      end

      def remove_reminder(reminder)
        Thread.new do
          ::Rails.logger.info("Deleting reminder #{reminder} for #{actor_type} #{actor_id}")
          Faraday.delete("#{Dapr::Rails.dapr_url}/v1.0/actors/#{actor_type}/#{actor_id}/reminders/#{reminder}")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end
      end

      def add_timer(timer, due_time, period)
        Thread.new do
          data = {
            dueTime: "0h0m#{due_time}s0ms",
            period: "0h0m#{period}s0ms"
          }
          ::Rails.logger.info("Setting timer #{timer} for #{actor_type} #{actor_id}")
          Faraday.post("#{Dapr::Rails.dapr_url}/v1.0/actors/#{actor_type}/#{actor_id}/timers/#{timer}",
                       data.to_json, "Content-Type" => "application/json")
        rescue StandardError => ex
          ::Rails.logger.error(ex.inspect)
          raise
        end
      end

      def deactivate
        save_state
        self.class.remove_actor(self)
        ::Rails.logger.info("DEACTIVATED actor #{actor_type} #{actor_id}")
      end

      def fetch_state
        @state = deserialize(store[state_key]).with_indifferent_access.tap do |value|
          ::Rails.logger.info("Read state for #{actor_type} #{actor_id}: #{value}")
        end
      end

      def save_state
        # ::Rails.logger.info("Saving state for #{actor_type} #{actor_id}: #{state}")
        data = serialize(state)
        if state.empty?
          store.delete(state_key)
        else
          store[state_key] = data
        end
        ::Rails.logger.info("Saved state for #{actor_type} #{actor_id}: #{state}")
      end

      private

      attr_reader :client, :store, :state, :actor_type, :actor_id

      def state_key
        @_state_key ||= [
          Dapr::Rails.app_id,
          actor_type,
          actor_id
        ].join("-")
      end

      def deserialize(data)
        return Hash.new if data.empty?

        JSON.parse(data)
      end

      def serialize(state)
        return if state.empty?

        state.to_json
      end
    end
  end
end