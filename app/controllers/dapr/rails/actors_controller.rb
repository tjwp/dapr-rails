# frozen_string_literal: true

module Dapr
  module Rails
    class ActorsController < Dapr::Rails::ApplicationController
      before_action :supported_actor_type
      before_action :fetch_actor_class

      def invoke
        ::Rails.logger.debug("actor params: #{params[:actor]}")
        result = actor_class.invoke(actor_type: params[:actor_type],
                           actor_id: params[:actor_id],
                           method: params[:method],
                           data: params[:actor].permit!)

        render json: result
      end

      def delete
        result = actor_class.deactivate_actor(params[:actor_id])
        if result
          render status: :ok, json: result
        else
          head :not_found
        end
      end

      def remind
        _result = actor_class.invoke_reminder(actor_type: params[:actor_type],
                                             actor_id: params[:actor_id],
                                             reminder: params[:reminder])
        head :ok
      end

      def timer
        _result = actor_class.invoke_timer(actor_type: params[:actor_type],
                                          actor_id: params[:actor_id],
                                          timer: params[:timer])
        head :ok
      end

      private

      attr_reader :actor_class

      def supported_actor_type
        head :not_found unless Dapr::Rails.actor_registry.key?(params[:actor_type])
      end

      def fetch_actor_class
        @actor_class = Dapr::Rails.actor_class(params[:actor_type])
      end
    end
  end
end