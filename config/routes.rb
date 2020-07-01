Dapr::Rails::Engine.routes.draw do
  defaults format: :json do
    scope "/dapr" do
      get "config", to: "config#show"

      get "subscribe", to: "topics#index"
    end

    get "healthz", to: "health#show"

    scope "/actors" do
      put ":actor_type/:actor_id/method/remind/:reminder", to: "actors#remind"

      put ":actor_type/:actor_id/method/timer/:timer", to: "actors#timer"

      put ":actor_type/:actor_id/method/:method", to: "actors#invoke"

      delete ":actor_type/:actor_id", to: "actors#delete"
    end

    match "*path", via: :options,
          to: ->(_env) { [404, { 'Content-Type' => 'text/plain' }, ["Not Found\n"]] }
  end
end
