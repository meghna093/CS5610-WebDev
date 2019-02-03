defmodule StormchatWeb.AlertController do
  use StormchatWeb, :controller

  alias Stormchat.Alerts

  action_fallback StormchatWeb.FallbackController

  # returns a list of a certain number of the verified user's alerts by type
  # valid types...
  # active: the latest chunk of active alerts for the verified user
  # active_older: an older chunk of active alerts for the verified user
  # historical: the latest chunk of historical alerts for the verified user
  # historical_older: an older chunk of historical alerts for the verified user
  # for older, alert_id should be the oldest current alert
  def index(conn, params) do
    case Phoenix.Token.verify(conn, "auth token", params["token"], max_age: 86400) do
      {:ok, user_id} ->
        type = params["type"]

        alerts =
          case type do
            "active_by_location" -> Alerts.get_active_by_location(user_id, params["location_id"])
            "active_older_by_location" -> Alerts.get_older_active_by_location(user_id, params["location_id"], params["alert_id"])
            "historical_by_location" -> Alerts.get_historical_by_location(user_id, params["location_id"])
            "historical_older_by_location" -> Alerts.get_older_historical_by_location(user_id, params["location_id"], params["alert_id"])
            "active_by_latlong" -> Alerts.get_active_by_latlong(params["lat"], params["long"])
            "active_older_by_latlong" -> Alerts.get_older_active_by_latlong(params["lat"], params["long"], params["alert_id"])
            "historical_by_latlong" -> Alerts.get_historical_by_latlong(params["lat"], params["long"])
            "historical_older_by_latlong" -> Alerts.get_older_historical_by_latlong(params["lat"], params["long"], params["alert_id"])
            _else -> []
          end

        render(conn, "index.json", alerts: alerts)
      _else ->
        conn
        |> put_status(401)
        |> render(conn, %{error: "TOKEN_UNAUTHORIZED"})
    end
  end
end
