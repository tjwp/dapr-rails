# frozen_string_literal: true

module Dapr
  module Rails
    class ActorsController < Dapr::Rails::ApplicationController
      def invoke
        head :not_found unless Dapr::Rails.actor_registry.key?(params[:actor_type])

        actor_class = Dapr::Rails.actor_class(params[:actor_type])

        puts params.inspect
        result = actor_class.invoke(actor_type: params[:actor_type],
                           actor_id: params[:actor_id],
                           method: params[:method],
                           data: params[:actor])

        render json: result
      end

      def delete

      end

      def remind

      end

      def timer

      end
    end
  end
end