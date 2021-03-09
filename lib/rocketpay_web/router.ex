defmodule RocketpayWeb.Router do
  use RocketpayWeb, :router

  import Plug.BasicAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  #Os plugs são como os middlewares que existem no Express.js, por exemplo.
  #Neste exemplo, o plug [:basic_auth] ja vem criado por padrão com Phoenix e só esta sendo "reutilizado"
  #Mas há formas de criar plugs personalizados de acordo com a necessidade
  pipeline :auth do
    plug :basic_auth, Application.compile_env(:rocketpay, :basic_auth)
  end

  scope "/api", RocketpayWeb do
    pipe_through :api

    post "/users", UsersController, :create

    # post "/accounts/:id/deposit", AccountsController, :deposit
    # post "/accounts/:id/withdraw", AccountsController, :withdraw
    # post "/accounts/transaction", AccountsController, :transaction
  end

  scope "/api", RocketpayWeb do
    pipe_through [:api, :auth]  #Este [pipe_through] indica que o plug sera usado nas rotas que sussederem ele, no caso, todas as rotas de [accounts]

    post "/accounts/:id/deposit", AccountsController, :deposit
    post "/accounts/:id/withdraw", AccountsController, :withdraw
    post "/accounts/transaction", AccountsController, :transaction
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: RocketpayWeb.Telemetry
    end
  end
end
