defmodule VeCollector.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      VeCollector.Repo,
      # Start the Telemetry supervisor
      VeCollectorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: VeCollector.PubSub},
      # Start the Endpoint (http/https)
      VeCollectorWeb.Endpoint,
      # Cleartext parser
      {VeCollector.VE.ClearText, []},
      {VeCollector.VE.ClearText.Store, []},
      # TODO: maybe build as a Dynamic Module Supervisor and give it a different name
      {DynamicSupervisor, name: VeCollector.SerialSupervisor, strategy: :one_for_one},
      # Serial Discovery service
      {VeCollector.Serial.Discover, []},
      # Serial device registry
      {VeCollector.Serial.Store, []}
      # Start a worker by calling: VeCollector.Worker.start_link(arg)
      # {VeCollector.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VeCollector.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VeCollectorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
