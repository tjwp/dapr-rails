# frozen_string_literal: true

module Dapr
  module Rails
    class HealthController < Dapr::Rails::ApplicationController
      def show
        head :ok
      end
    end
  end
end