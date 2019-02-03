defmodule Stormchat.LocationsTest do
  use Stormchat.DataCase

  alias Stormchat.Locations

  describe "locations" do
    alias Stormchat.Locations.Location

    @valid_attrs %{description: "some description", lat: 120.5, long: 120.5}
    @update_attrs %{description: "some updated description", lat: 456.7, long: 456.7}
    @invalid_attrs %{description: nil, lat: nil, long: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locations.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Locations.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Locations.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = Locations.create_location(@valid_attrs)
      assert location.description == "some description"
      assert location.lat == 120.5
      assert location.long == 120.5
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, location} = Locations.update_location(location, @update_attrs)
      assert %Location{} = location
      assert location.description == "some updated description"
      assert location.lat == 456.7
      assert location.long == 456.7
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_location(location, @invalid_attrs)
      assert location == Locations.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Locations.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Locations.change_location(location)
    end
  end

  describe "location_counties" do
    alias Stormchat.Locations.LocationCounty

    @valid_attrs %{fips_code: "some fips_code"}
    @update_attrs %{fips_code: "some updated fips_code"}
    @invalid_attrs %{fips_code: nil}

    def location_county_fixture(attrs \\ %{}) do
      {:ok, location_county} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locations.create_location_county()

      location_county
    end

    test "list_location_counties/0 returns all location_counties" do
      location_county = location_county_fixture()
      assert Locations.list_location_counties() == [location_county]
    end

    test "get_location_county!/1 returns the location_county with given id" do
      location_county = location_county_fixture()
      assert Locations.get_location_county!(location_county.id) == location_county
    end

    test "create_location_county/1 with valid data creates a location_county" do
      assert {:ok, %LocationCounty{} = location_county} = Locations.create_location_county(@valid_attrs)
      assert location_county.fips_code == "some fips_code"
    end

    test "create_location_county/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_location_county(@invalid_attrs)
    end

    test "update_location_county/2 with valid data updates the location_county" do
      location_county = location_county_fixture()
      assert {:ok, location_county} = Locations.update_location_county(location_county, @update_attrs)
      assert %LocationCounty{} = location_county
      assert location_county.fips_code == "some updated fips_code"
    end

    test "update_location_county/2 with invalid data returns error changeset" do
      location_county = location_county_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_location_county(location_county, @invalid_attrs)
      assert location_county == Locations.get_location_county!(location_county.id)
    end

    test "delete_location_county/1 deletes the location_county" do
      location_county = location_county_fixture()
      assert {:ok, %LocationCounty{}} = Locations.delete_location_county(location_county)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_location_county!(location_county.id) end
    end

    test "change_location_county/1 returns a location_county changeset" do
      location_county = location_county_fixture()
      assert %Ecto.Changeset{} = Locations.change_location_county(location_county)
    end
  end
end
