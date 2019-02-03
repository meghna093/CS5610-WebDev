defmodule StormchatWeb.LocationView do
  use StormchatWeb, :view
  alias StormchatWeb.LocationView

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location.json")}
  end

  def render("show.json", %{location: location}) do
    %{data: render_one(location, LocationView, "location.json")}
  end

  def render("location.json", %{location: location}) do
    %{id: location.id,
      lat: location.lat,
      long: location.long,
      description: location.description}
  end
end
