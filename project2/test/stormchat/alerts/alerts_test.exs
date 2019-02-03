defmodule Stormchat.AlertsTest do
  use Stormchat.DataCase

  alias Stormchat.Alerts

  describe "alerts" do
    alias Stormchat.Alerts.Alert

    @valid_attrs %{areaDesc: "some areaDesc", category: "some category", certainty: "some certainty", description: "some description", effective: "2010-04-17 14:00:00.000000Z", event: "some event", expires: "2010-04-17 14:00:00.000000Z", identifier: "some identifier", instruction: "some instruction", severity: "some severity", summary: "some summary", title: "some title", urgency: "some urgency"}
    @update_attrs %{areaDesc: "some updated areaDesc", category: "some updated category", certainty: "some updated certainty", description: "some updated description", effective: "2011-05-18 15:01:01.000000Z", event: "some updated event", expires: "2011-05-18 15:01:01.000000Z", identifier: "some updated identifier", instruction: "some updated instruction", severity: "some updated severity", summary: "some updated summary", title: "some updated title", urgency: "some updated urgency"}
    @invalid_attrs %{areaDesc: nil, category: nil, certainty: nil, description: nil, effective: nil, event: nil, expires: nil, identifier: nil, instruction: nil, severity: nil, summary: nil, title: nil, urgency: nil}

    def alert_fixture(attrs \\ %{}) do
      {:ok, alert} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Alerts.create_alert()

      alert
    end

    test "list_alerts/0 returns all alerts" do
      alert = alert_fixture()
      assert Alerts.list_alerts() == [alert]
    end

    test "get_alert!/1 returns the alert with given id" do
      alert = alert_fixture()
      assert Alerts.get_alert!(alert.id) == alert
    end

    test "create_alert/1 with valid data creates a alert" do
      assert {:ok, %Alert{} = alert} = Alerts.create_alert(@valid_attrs)
      assert alert.areaDesc == "some areaDesc"
      assert alert.category == "some category"
      assert alert.certainty == "some certainty"
      assert alert.description == "some description"
      assert alert.effective == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert alert.event == "some event"
      assert alert.expires == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert alert.identifier == "some identifier"
      assert alert.instruction == "some instruction"
      assert alert.severity == "some severity"
      assert alert.summary == "some summary"
      assert alert.title == "some title"
      assert alert.urgency == "some urgency"
    end

    test "create_alert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Alerts.create_alert(@invalid_attrs)
    end

    test "update_alert/2 with valid data updates the alert" do
      alert = alert_fixture()
      assert {:ok, alert} = Alerts.update_alert(alert, @update_attrs)
      assert %Alert{} = alert
      assert alert.areaDesc == "some updated areaDesc"
      assert alert.category == "some updated category"
      assert alert.certainty == "some updated certainty"
      assert alert.description == "some updated description"
      assert alert.effective == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert alert.event == "some updated event"
      assert alert.expires == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert alert.identifier == "some updated identifier"
      assert alert.instruction == "some updated instruction"
      assert alert.severity == "some updated severity"
      assert alert.summary == "some updated summary"
      assert alert.title == "some updated title"
      assert alert.urgency == "some updated urgency"
    end

    test "update_alert/2 with invalid data returns error changeset" do
      alert = alert_fixture()
      assert {:error, %Ecto.Changeset{}} = Alerts.update_alert(alert, @invalid_attrs)
      assert alert == Alerts.get_alert!(alert.id)
    end

    test "delete_alert/1 deletes the alert" do
      alert = alert_fixture()
      assert {:ok, %Alert{}} = Alerts.delete_alert(alert)
      assert_raise Ecto.NoResultsError, fn -> Alerts.get_alert!(alert.id) end
    end

    test "change_alert/1 returns a alert changeset" do
      alert = alert_fixture()
      assert %Ecto.Changeset{} = Alerts.change_alert(alert)
    end
  end

  describe "counties" do
    alias Stormchat.Alerts.County

    @valid_attrs %{fips_code: "some fips_code"}
    @update_attrs %{fips_code: "some updated fips_code"}
    @invalid_attrs %{fips_code: nil}

    def county_fixture(attrs \\ %{}) do
      {:ok, county} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Alerts.create_county()

      county
    end

    test "list_counties/0 returns all counties" do
      county = county_fixture()
      assert Alerts.list_counties() == [county]
    end

    test "get_county!/1 returns the county with given id" do
      county = county_fixture()
      assert Alerts.get_county!(county.id) == county
    end

    test "create_county/1 with valid data creates a county" do
      assert {:ok, %County{} = county} = Alerts.create_county(@valid_attrs)
      assert county.fips_code == "some fips_code"
    end

    test "create_county/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Alerts.create_county(@invalid_attrs)
    end

    test "update_county/2 with valid data updates the county" do
      county = county_fixture()
      assert {:ok, county} = Alerts.update_county(county, @update_attrs)
      assert %County{} = county
      assert county.fips_code == "some updated fips_code"
    end

    test "update_county/2 with invalid data returns error changeset" do
      county = county_fixture()
      assert {:error, %Ecto.Changeset{}} = Alerts.update_county(county, @invalid_attrs)
      assert county == Alerts.get_county!(county.id)
    end

    test "delete_county/1 deletes the county" do
      county = county_fixture()
      assert {:ok, %County{}} = Alerts.delete_county(county)
      assert_raise Ecto.NoResultsError, fn -> Alerts.get_county!(county.id) end
    end

    test "change_county/1 returns a county changeset" do
      county = county_fixture()
      assert %Ecto.Changeset{} = Alerts.change_county(county)
    end
  end
end
