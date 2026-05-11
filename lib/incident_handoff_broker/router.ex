defmodule IncidentHandoffBroker.Router do
  @moduledoc false

  use Plug.Router

  alias IncidentHandoffBroker.HandoffEngine

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/" do
    json(conn, 200, %{
      service: "incident-handoff-broker",
      language: "Elixir",
      description: "Incident intake, ownership routing, and SLA-aware handoff analysis.",
      endpoints: [
        "/docs",
        "/api/dashboard/summary",
        "/api/incidents/:id",
        "/api/sample",
        "/api/analyze/handoff"
      ]
    })
  end

  get "/docs" do
    html =
      """
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8" />
          <title>Incident Handoff Broker Docs</title>
          <style>
            body { font-family: Segoe UI, sans-serif; background:#0b1220; color:#f3efe6; margin:0; padding:32px; }
            .shell { max-width:920px; margin:0 auto; background:#151d30; border:1px solid #223253; border-radius:20px; padding:28px; }
            h1 { margin:0 0 8px; font-size:40px; }
            p, li, code { color:#d2d7e6; }
            code { background:#0e1626; padding:2px 6px; border-radius:6px; }
          </style>
        </head>
        <body>
          <div class="shell">
            <p style="letter-spacing:0.25em;text-transform:uppercase;color:#7ec3ff;">Incident Handoff Broker</p>
            <h1>Live Elixir control surface for operational handoffs.</h1>
            <p>This service takes incident pressure from ops, growth, AI, and security lanes and turns it into ownership-aware routing decisions.</p>
            <ul>
              <li><code>GET /api/dashboard/summary</code> returns live handoff posture.</li>
              <li><code>GET /api/incidents/:id</code> returns an incident thread.</li>
              <li><code>GET /api/sample</code> returns a sample analysis.</li>
              <li><code>POST /api/analyze/handoff</code> scores a payload and returns the next action.</li>
            </ul>
          </div>
        </body>
      </html>
      """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  get "/api/dashboard/summary" do
    json(conn, 200, HandoffEngine.summary())
  end

  get "/api/incidents" do
    json(conn, 200, %{incidents: HandoffEngine.incidents()})
  end

  get "/api/incidents/:id" do
    case HandoffEngine.incident(id) do
      nil -> json(conn, 404, %{error: "incident_not_found", id: id})
      incident -> json(conn, 200, incident)
    end
  end

  get "/api/sample" do
    json(conn, 200, HandoffEngine.sample_analysis())
  end

  post "/api/analyze/handoff" do
    json(conn, 200, HandoffEngine.analyze(conn.body_params))
  end

  match _ do
    json(conn, 404, %{error: "not_found"})
  end

  defp json(conn, status, payload) do
    body = Jason.encode!(payload)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end
end
