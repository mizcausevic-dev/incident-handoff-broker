defmodule IncidentHandoffBroker.HandoffEngine do
  @moduledoc false

  alias IncidentHandoffBroker.SampleData

  @severity_weight %{
    "low" => 10,
    "medium" => 25,
    "high" => 45,
    "critical" => 65
  }

  def summary do
    incidents = incidents()

    critical_count =
      Enum.count(incidents, fn incident ->
        analyze(incident).status == "escalate"
      end)

    %{
      service: "incident-handoff-broker",
      total_incidents: length(incidents),
      active_handoffs: Enum.count(incidents, &(&1.bridge_state != "monitoring")),
      escalated_paths: critical_count,
      owner_gaps: Enum.count(incidents, &(&1.bridge_state == "owner-gap")),
      average_confidence:
        incidents
        |> Enum.map(& &1.confidence)
        |> average()
        |> Float.round(2)
    }
  end

  def incidents do
    SampleData.incidents()
  end

  def incident(id) do
    Enum.find(incidents(), &(&1.id == id))
  end

  def sample_analysis do
    incidents()
    |> List.first()
    |> analyze()
  end

  def analyze(%{} = payload) do
    pressure =
      severity_score(field(payload, :severity)) +
        sla_pressure(field(payload, :elapsed_hours), field(payload, :sla_hours)) +
        bridge_penalty(field(payload, :bridge_state)) +
        blocker_penalty(field(payload, :blockers)) +
        confidence_penalty(field(payload, :confidence))

    risk_score = min(100, pressure)

    status =
      cond do
        risk_score >= 80 -> "escalate"
        risk_score >= 50 -> "watch"
        true -> "stable"
      end

    %{
      incident_id: Map.get(payload, :id) || Map.get(payload, "id"),
      status: status,
      risk_score: risk_score,
      owner: owner_for(payload),
      escalation_lane: lane_for(payload, status),
      next_action: next_action(payload, status),
      why: rationale(payload, status)
    }
  end

  defp severity_score(severity), do: Map.get(@severity_weight, severity || "medium", 25)

  defp sla_pressure(elapsed_hours, sla_hours) do
    ratio = elapsed_hours / max(sla_hours, 1)

    cond do
      ratio >= 1.5 -> 25
      ratio >= 1.0 -> 18
      ratio >= 0.75 -> 10
      true -> 0
    end
  end

  defp bridge_penalty("owner-gap"), do: 18
  defp bridge_penalty("war-room-active"), do: 8
  defp bridge_penalty(_), do: 0

  defp blocker_penalty(blockers) when is_list(blockers), do: min(length(blockers) * 7, 21)
  defp blocker_penalty(_), do: 0

  defp confidence_penalty(confidence) when confidence < 0.65, do: 12
  defp confidence_penalty(confidence) when confidence < 0.8, do: 6
  defp confidence_penalty(_), do: 0

  defp owner_for(%{target_team: target_team}), do: "#{target_team} lead"
  defp owner_for(%{"target_team" => target_team}), do: "#{target_team} lead"
  defp owner_for(_), do: "Operations lead"

  defp lane_for(%{severity: "critical"}, _status), do: "executive-war-room"
  defp lane_for(_payload, "escalate"), do: "cross-functional-escalation"
  defp lane_for(_payload, "watch"), do: "owner-confirmation"
  defp lane_for(_payload, "stable"), do: "monitoring"

  defp next_action(payload, "escalate") do
    next_steps(payload)
    |> List.first()
    |> Kernel.||("Open an executive bridge and pin ownership immediately")
  end

  defp next_action(_payload, "watch") do
    "Hold the handoff lane in watch mode and confirm the next owner within one cycle"
  end

  defp next_action(_payload, "stable") do
    "Keep the lane warm, update the timeline, and review after the next ingest window"
  end

  defp rationale(payload, status) do
    %{
      source_team: team(payload, :source_team),
      target_team: team(payload, :target_team),
      bridge_state: field(payload, :bridge_state),
      blockers: field(payload, :blockers),
      dependent_teams: field(payload, :dependent_teams),
      status_reason:
        case status do
          "escalate" -> "Multiple pressures are stacked and the handoff needs a command path."
          "watch" -> "The path is still recoverable, but ownership confirmation cannot drift."
          _ -> "The path is contained and can stay under operator review."
        end
    }
  end

  defp team(payload, key), do: field(payload, key)

  defp next_steps(payload) do
    field(payload, :next_steps) || []
  end

  defp field(payload, key) do
    Map.get(payload, key) || Map.get(payload, Atom.to_string(key))
  end

  defp average([]), do: 0.0
  defp average(values), do: Enum.sum(values) / length(values)
end
