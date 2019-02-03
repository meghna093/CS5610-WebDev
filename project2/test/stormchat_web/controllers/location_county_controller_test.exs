defmodule StormchatWeb.LocationCountyControllerTest do
  use StormchatWeb.ConnCase

  alias Stormchat.Locations
  alias Stormchat.Locations.LocationCounty

  @create_attrs %{fips_code: "some fips_code"}
  @update_attrs %{fips_code: "some updated fips_code"}
  @invalid_attrs %{fips_code: nil}

  def fixture(:location_county) do
    {:ok, location_county} = Locations.create_location_county(@create_attrs)
    location_county
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all location_counties", %{conn: conn} do
      conn = get conn, location_county_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create location_county" do
    test "renders location_county when data is valid", %{conn: conn} do
      conn = post conn, location_county_path(conn, :create), location_county: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, location_county_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "fips_code" => "some fips_code"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, location_county_path(conn, :create), location_county: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update location_county" do
    setup [:create_location_county]

    test "renders location_county when data is valid", %{conn: conn, location_county: %LocationCounty{id: id} = location_county} do
      conn = put conn, location_county_path(conn, :update, location_county), location_county: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, location_county_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "fips_code" => "some updated fips_code"}
    end

    test "renders errors when data is invalid", %{conn: conn, location_county: location_county} do
      conn = put conn, location_county_path(conn, :update, location_county), location_county: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete location_county" do
    setup [:create_location_county]

    test "deletes chosen location_county", %{conn: conn, location_county: location_county} do
      conn = delete conn, location_county_path(conn, :delete, location_county)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, location_county_path(conn, :show, location_county)
      end
    end
  end

  defp create_location_county(_) do
    location_county = fixture(:location_county)
    {:ok, location_county: location_county}
  end
end
