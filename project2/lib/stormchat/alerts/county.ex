defmodule Stormchat.Alerts.County do
  use Ecto.Schema
  import Ecto.Changeset

  # an alert can be for multiple counties
  # each county references the alert it is associated with

  schema "counties" do
    field :fips_code, :string
    belongs_to :alert, Stormchat.Alerts.Alert

    timestamps()
  end

  @doc false
  def changeset(county, attrs) do
    county
    |> cast(attrs, [:fips_code, :alert_id])
    |> validate_required([:fips_code, :alert_id])
  end
end
