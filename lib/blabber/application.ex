defmodule Blabber.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Blabber.FlanT5, []},
      {Blabber.Distilbert, []},
      BlabberWeb.Telemetry,
      Blabber.Repo,
      {DNSCluster, query: Application.get_env(:blabber, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Blabber.PubSub}
      # Start a worker by calling: Blabber.Worker.start_link(arg)
      # {Blabber.Worker, arg},
      # Start to serve requests, typically the last entry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blabber.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlabberWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
