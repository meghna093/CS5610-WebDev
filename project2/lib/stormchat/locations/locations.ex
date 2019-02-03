defmodule Stormchat.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias Stormchat.Repo

  alias Stormchat.Locations.Location
  alias Stormchat.Locations.LocationCounty
  alias Stormchat.Alerts
  alias Stormchat.Locations.CountyPolygons

  # returns a list of polygons affected by the given alert
  def get_affected_polygons(alert_id) do
    Alerts.get_affected_fips(alert_id)
    |> Enum.map(fn(fc)->  CountyPolygons.get_county_polygons_by_fips(fc) end)
    #    |> List.flatten()
  end

  # returns a list of fips codes encompassing or nearby the given coordinates
  # fuzziness built into datasciencetoolkit api
  def get_fips_by_latlong(lat, long) do
    base_path = "http://www.datasciencetoolkit.org/coordinates2politics/"
    url = base_path <> Float.to_string(lat) <> "%2c" <> Float.to_string(long)

    {msg, resp} = HTTPoison.get(url)

    case msg do
      :error ->
        IO.puts("http error getting fips from datasciencetoolkit api")
        IO.inspect(resp)
        get_fips_by_latlong(lat, long)
      :ok ->
        {m, r} = Poison.decode(resp.body)

        case m do
          :error ->
            IO.puts("error decoding datascience toolkit fips jason response")
            IO.inspect(r)
          :ok ->
            [first | _rest] = r
            Enum.filter(first["politics"], fn(pp) -> pp["type"] == "admin6" end)
            |> Enum.map(fn(pp) -> "0" <> String.replace(pp["code"], "_", "") end)
        end
    end
  end

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  # returns a list of the given user's saved locations
  def list_locations_by_user_id(user_id) do
    query =
      from l in Location,
        where: l.user_id == ^user_id

    Repo.all(query)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  def get_location(id), do: Repo.get(Location, id)

  def get_location_id(lat, long, user_id) do
    query = from l in Location,
      where: l.lat == ^lat and l.long == ^long and l.user_id == ^user_id

    location = Repo.one(query)

    location.id
  end

  @doc """
  Creates a location, gets fips codes associated with that locations,
  and creates the associdated location_counties

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    # create location record
    {msg, changeset} = %Location{}
      |> Location.changeset(attrs)
      |> Repo.insert()

    # make sure location creation was successful
    case msg do
      :ok ->
        lat = attrs["lat"]
        long = attrs["long"]
        user_id = attrs["user_id"]
        IO.inspect(attrs)

        # get id of newly created location
        location_id = get_location_id(lat, long, user_id)

        # get fips codes associated with this location
        # and create a location_county for each fips code
        get_fips_by_latlong(lat, long)
        |> Enum.each(fn(fc) ->
          create_location_county(%{location_id: location_id, fips_code: fc})
          end)

        {msg, changeset}
      :error ->
        {msg, changeset}
    end
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}

  """
  def change_location(%Location{} = location) do
    Location.changeset(location, %{})
  end

  @doc """
  Returns the list of location counties.

  ## Examples

      iex> list_location)counties()
      [%LocationCounty{}, ...]

  """
  def list_location_counties do
    Repo.all(LocationCounty)
  end

  @doc """
  Gets a single location_county.

  Raises `Ecto.NoResultsError` if the LocationCounty does not exist.

  ## Examples

      iex> get_location_county!(123)
      %LocationCounty{}

      iex> get_location_county!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location_county!(id), do: Repo.get!(LocationCounty, id)

  @doc """
  Creates a location_county.

  ## Examples

      iex> create_location_county(%{field: value})
      {:ok, %LocationCounty{}}

      iex> create_location_county(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location_county(attrs \\ %{}) do
    %LocationCounty{}
    |> LocationCounty.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location_county.

  ## Examples

      iex> update_location_county(location_county, %{field: new_value})
      {:ok, %LocationCounty{}}

      iex> update_location_county(location_county, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location_county(%LocationCounty{} = location_county, attrs) do
    location_county
    |> LocationCounty.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LocationCounty.

  ## Examples

      iex> delete_location_county(location_county)
      {:ok, %LocationCounty{}}

      iex> delete_location_county(location_county)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location_county(%LocationCounty{} = location_county) do
    Repo.delete(location_county)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location_county changes.

  ## Examples

      iex> change_location_county(location_county)
      %Ecto.Changeset{source: %LocationCounty{}}

  """
  def change_location_county(%LocationCounty{} = location_county) do
    LocationCounty.changeset(location_county, %{})
  end
end
