defmodule IncidentHandoffBroker.SampleData do
  @moduledoc false

  def incidents do
    [
      %{
        id: "inc-4102",
        title: "Checkout latency spike is bouncing between platform and revenue ops",
        source_team: "Platform Reliability",
        target_team: "Revenue Systems",
        severity: "critical",
        sla_hours: 2,
        elapsed_hours: 3.4,
        blast_radius: "enterprise_checkout",
        bridge_state: "war-room-active",
        confidence: 0.78,
        blockers: [
          "Payment retry path is rate limited by edge policy",
          "Promo service dependency was rolled back but cache invalidation is incomplete"
        ],
        dependent_teams: ["Platform Reliability", "Revenue Systems", "Support"],
        timeline: [
          "19:05 ET - Elevated cart drop alerts fired",
          "19:18 ET - Edge rate controls tightened in EU lane",
          "19:34 ET - Support escalated three strategic account complaints"
        ],
        next_steps: [
          "Shift checkout traffic to hardened recovery lane",
          "Pin cache invalidation ownership to revenue systems lead"
        ]
      },
      %{
        id: "inc-4107",
        title: "Shadow AI policy breach needs governance handoff before customer expansion",
        source_team: "AI Governance",
        target_team: "Security Operations",
        severity: "high",
        sla_hours: 8,
        elapsed_hours: 5.5,
        blast_radius: "regional_accounts",
        bridge_state: "owner-gap",
        confidence: 0.61,
        blockers: [
          "Two contractors still have stale scoped API keys",
          "Exception note was captured in chat but not in the system of record"
        ],
        dependent_teams: ["AI Governance", "Security Operations", "Legal"],
        timeline: [
          "09:11 ET - Red-team finding flagged data retention drift",
          "10:06 ET - Legal requested evidence bundle",
          "12:42 ET - Security follow-up owner still not assigned"
        ],
        next_steps: [
          "Assign security owner for evidence bundle assembly",
          "Freeze downstream access until the exception is logged"
        ]
      },
      %{
        id: "inc-4114",
        title: "Partner lead routing mismatch is delaying SLA commitments",
        source_team: "Demand Operations",
        target_team: "Partner Success",
        severity: "medium",
        sla_hours: 24,
        elapsed_hours: 11.2,
        blast_radius: "partner_pipeline",
        bridge_state: "monitoring",
        confidence: 0.88,
        blockers: [
          "Lead source taxonomy drifted after campaign relaunch"
        ],
        dependent_teams: ["Demand Operations", "Partner Success"],
        timeline: [
          "07:20 ET - Routing queue backlog exceeded baseline",
          "10:15 ET - Attribution mapping patched for new campaign source"
        ],
        next_steps: [
          "Backfill source taxonomy mapping",
          "Leave partner handoff lane in watch mode for one business cycle"
        ]
      }
    ]
  end
end
