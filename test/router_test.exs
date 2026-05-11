defmodule IncidentHandoffBroker.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias IncidentHandoffBroker.Router

  @opts Router.init([])

  test "root route returns service metadata" do
    conn =
      :get
      |> conn("/")
      |> Router.call(@opts)

    assert conn.status == 200
    assert conn.resp_body =~ "incident-handoff-broker"
  end

  test "sample route returns analysis" do
    conn =
      :get
      |> conn("/api/sample")
      |> Router.call(@opts)

    assert conn.status == 200
    assert conn.resp_body =~ "\"status\""
  end
end
