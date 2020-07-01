# frozen_string_literal: true

module Dapr
  module Rails
    class TopicsController < Dapr::Rails::ApplicationController
      def index
        render json: Dapr::Rails.topics
      end
    end
  end
end