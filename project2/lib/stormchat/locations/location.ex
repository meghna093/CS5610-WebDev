defmodule Stormchat.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  # to store users' saved locations that they'd like notifications for

  schema "locations" do
    field :description, :string
    field :lat, :float
    field :long, :float
    belongs_to :user, Stormchat.Users.User

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:lat, :long, :description, :user_id])
    |> validate_required([:lat, :long, :description, :user_id])
    |> unique_constraint(:lat, name: :locations_lat_long_user_id_index)
  end
end
