defmodule IncidentHandoffBroker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: IncidentHandoffBroker.Router, options: [port: port()]}
    ]

    opts = [strategy: :one_for_one, name: IncidentHandoffBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    System.get_env("PORT", "4051")
    |> String.to_integer()
  end
end
