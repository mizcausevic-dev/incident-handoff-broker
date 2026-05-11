defmodule IncidentHandoffBroker.HandoffEngineTest do
  use ExUnit.Case, async: true

  alias IncidentHandoffBroker.HandoffEngine

  test "summary returns portfolio posture" do
    summary = HandoffEngine.summary()

    assert summary.service == "incident-handoff-broker"
    assert summary.total_incidents == 3
    assert summary.active_handoffs >= 1
  end

  test "critical payload escalates into command path" do
    payload = %{
      "id" => "inc-x",
      "source_team" => "Platform",
      "target_team" => "Security",
      "severity" => "critical",
      "sla_hours" => 1,
      "elapsed_hours" => 2.1,
      "bridge_state" => "owner-gap",
      "confidence" => 0.52,
      "blockers" => ["one", "two"],
      "dependent_teams" => ["Platform", "Security"],
      "next_steps" => ["Open bridge now"]
    }

    result = HandoffEngine.analyze(payload)

    assert result.status == "escalate"
    assert result.risk_score >= 80
    assert result.next_action == "Open bridge now"
  end
end
