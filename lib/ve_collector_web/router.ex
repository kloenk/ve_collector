defmodule VeCollectorWeb.Router do
  use VeCollectorWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug VeCollectorWeb.Plugs.EnsureRole, :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :metrics do
    plug :accepts, ["text"]
    plug VeCollectorWeb.Plugs.ContentVersion, "text/plain; version=0.0.4"
    plug VeCollectorWeb.Plugs.ApplicationName, "ve_collector"
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
  end

  scope "/", VeCollectorWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Pow user Routes
  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser, :protected]

    resources "/registration", RegistrationController,
      singleton: true,
      only: [:edit, :update, :delete]
  end

  # Live Dashboard router
  scope "/" do
    import Phoenix.LiveDashboard.Router
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: VeCollectorWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  scope "/api", VeCollectorWeb do
    pipe_through :api
  end

  scope "/metrics", VeCollectorWeb do
    pipe_through :metrics

    get "/", MetricController, :index
    get "/:port", MetricController, :port
  end
end
