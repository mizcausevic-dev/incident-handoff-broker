defmodule IncidentHandoffBroker do
  @moduledoc """
  Public API for the incident handoff broker.
  """

  alias IncidentHandoffBroker.HandoffEngine

  defdelegate summary, to: HandoffEngine
  defdelegate incident(id), to: HandoffEngine
  defdelegate incidents, to: HandoffEngine
  defdelegate analyze(payload), to: HandoffEngine
  defdelegate sample_analysis, to: HandoffEngine
end
