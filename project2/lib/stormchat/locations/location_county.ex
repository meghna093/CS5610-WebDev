defmodule Stormchat.Locations.LocationCounty do
  use Ecto.Schema
  import Ecto.Changeset

  # each saved location can be associated with multiple counties
  # as the datasciencetoolkit api that converts lat/long to counties
  # can return multiple counties for a single lat/long

  schema "location_counties" do
    field :fips_code, :string
    belongs_to :location, Stormchat.Locations.Location

    timestamps()
  end

  @doc false
  def changeset(location_county, attrs) do
    location_county
    |> cast(attrs, [:fips_code, :location_id])
    |> validate_required([:fips_code, :location_id])
  end
end
