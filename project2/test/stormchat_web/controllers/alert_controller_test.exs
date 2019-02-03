defmodule StormchatWeb.AlertControllerTest do
  use StormchatWeb.ConnCase

  alias Stormchat.Alerts
  alias Stormchat.Alerts.Alert

  @create_attrs %{areaDesc: "some areaDesc", category: "some category", certainty: "some certainty", description: "some description", effective: "2010-04-17 14:00:00.000000Z", event: "some event", expires: "2010-04-17 14:00:00.000000Z", identifier: "some identifier", instruction: "some instruction", severity: "some severity", summary: "some summary", title: "some title", urgency: "some urgency"}
  @update_attrs %{areaDesc: "some updated areaDesc", category: "some updated category", certainty: "some updated certainty", description: "some updated description", effective: "2011-05-18 15:01:01.000000Z", event: "some updated event", expires: "2011-05-18 15:01:01.000000Z", identifier: "some updated identifier", instruction: "some updated instruction", severity: "some updated severity", summary: "some updated summary", title: "some updated title", urgency: "some updated urgency"}
  @invalid_attrs %{areaDesc: nil, category: nil, certainty: nil, description: nil, effective: nil, event: nil, expires: nil, identifier: nil, instruction: nil, severity: nil, summary: nil, title: nil, urgency: nil}

  def fixture(:alert) do
    {:ok, alert} = Alerts.create_alert(@create_attrs)
    alert
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all alerts", %{conn: conn} do
      conn = get conn, alert_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create alert" do
    test "renders alert when data is valid", %{conn: conn} do
      conn = post conn, alert_path(conn, :create), alert: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, alert_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "areaDesc" => "some areaDesc",
        "category" => "some category",
        "certainty" => "some certainty",
        "description" => "some description",
        "effective" => "2010-04-17 14:00:00.000000Z",
        "event" => "some event",
        "expires" => "2010-04-17 14:00:00.000000Z",
        "identifier" => "some identifier",
        "instruction" => "some instruction",
        "severity" => "some severity",
        "summary" => "some summary",
        "title" => "some title",
        "urgency" => "some urgency"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, alert_path(conn, :create), alert: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update alert" do
    setup [:create_alert]

    test "renders alert when data is valid", %{conn: conn, alert: %Alert{id: id} = alert} do
      conn = put conn, alert_path(conn, :update, alert), alert: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, alert_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "areaDesc" => "some updated areaDesc",
        "category" => "some updated category",
        "certainty" => "some updated certainty",
        "description" => "some updated description",
        "effective" => "2011-05-18 15:01:01.000000Z",
        "event" => "some updated event",
        "expires" => "2011-05-18 15:01:01.000000Z",
        "identifier" => "some updated identifier",
        "instruction" => "some updated instruction",
        "severity" => "some updated severity",
        "summary" => "some updated summary",
        "title" => "some updated title",
        "urgency" => "some updated urgency"}
    end

    test "renders errors when data is invalid", %{conn: conn, alert: alert} do
      conn = put conn, alert_path(conn, :update, alert), alert: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete alert" do
    setup [:create_alert]

    test "deletes chosen alert", %{conn: conn, alert: alert} do
      conn = delete conn, alert_path(conn, :delete, alert)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, alert_path(conn, :show, alert)
      end
    end
  end

  defp create_alert(_) do
    alert = fixture(:alert)
    {:ok, alert: alert}
  end
end
