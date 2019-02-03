defmodule StormchatWeb.CountyControllerTest do
  use StormchatWeb.ConnCase

  alias Stormchat.Alerts
  alias Stormchat.Alerts.County

  @create_attrs %{fips_code: "some fips_code"}
  @update_attrs %{fips_code: "some updated fips_code"}
  @invalid_attrs %{fips_code: nil}

  def fixture(:county) do
    {:ok, county} = Alerts.create_county(@create_attrs)
    county
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all counties", %{conn: conn} do
      conn = get conn, county_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create county" do
    test "renders county when data is valid", %{conn: conn} do
      conn = post conn, county_path(conn, :create), county: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, county_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "fips_code" => "some fips_code"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, county_path(conn, :create), county: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update county" do
    setup [:create_county]

    test "renders county when data is valid", %{conn: conn, county: %County{id: id} = county} do
      conn = put conn, county_path(conn, :update, county), county: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, county_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "fips_code" => "some updated fips_code"}
    end

    test "renders errors when data is invalid", %{conn: conn, county: county} do
      conn = put conn, county_path(conn, :update, county), county: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete county" do
    setup [:create_county]

    test "deletes chosen county", %{conn: conn, county: county} do
      conn = delete conn, county_path(conn, :delete, county)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, county_path(conn, :show, county)
      end
    end
  end

  defp create_county(_) do
    county = fixture(:county)
    {:ok, county: county}
  end
end
