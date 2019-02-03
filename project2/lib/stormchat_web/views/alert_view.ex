defmodule StormchatWeb.AlertView do
  use StormchatWeb, :view
  alias StormchatWeb.AlertView

  def render("index.json", %{alerts: alerts}) do
    %{data: render_many(alerts, AlertView, "alert.json")}
  end

  def render("show.json", %{alert: alert}) do
    %{data: render_one(alert, AlertView, "alert.json")}
  end

  def render("error.json", data) do
    data
  end

  def render("alert.json", %{alert: alert}) do
    %{id: alert.id,
      identifier: alert.identifier,
      title: alert.title,
      summary: alert.summary,
      event: alert.event,
      effective: alert.effective,
      expires: alert.expires,
      urgency: alert.urgency,
      severity: alert.severity,
      certainty: alert.certainty,
      areaDesc: alert.areaDesc,
      description: alert.description,
      instruction: alert.instruction}
  end
end
