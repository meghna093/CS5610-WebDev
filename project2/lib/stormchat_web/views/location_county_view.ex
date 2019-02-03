defmodule StormchatWeb.LocationCountyView do
  use StormchatWeb, :view
  alias StormchatWeb.LocationCountyView

  def render("index.json", %{location_counties: location_counties}) do
    %{data: render_many(location_counties, LocationCountyView, "location_county.json")}
  end

  def render("show.json", %{location_county: location_county}) do
    %{data: render_one(location_county, LocationCountyView, "location_county.json")}
  end

  def render("location_county.json", %{location_county: location_county}) do
    %{id: location_county.id,
      fips_code: location_county.fips_code}
  end
end
