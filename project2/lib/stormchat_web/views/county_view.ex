defmodule StormchatWeb.CountyView do
  use StormchatWeb, :view
  alias StormchatWeb.CountyView

  def render("index.json", %{counties: counties}) do
    %{data: render_many(counties, CountyView, "county.json")}
  end

  def render("show.json", %{county: county}) do
    %{data: render_one(county, CountyView, "county.json")}
  end

  def render("county.json", %{county: county}) do
    %{id: county.id,
      fips_code: county.fips_code}
  end
end
