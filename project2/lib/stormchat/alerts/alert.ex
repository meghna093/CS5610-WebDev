defmodule Stormchat.Alerts.Alert do
  use Ecto.Schema
  import Ecto.Changeset


  schema "alerts" do
    field :areaDesc, :string
    field :certainty, :string
    field :description, :string
    field :effective, :utc_datetime
    field :event, :string
    field :expires, :utc_datetime
    field :identifier, :string
    field :instruction, :string
    field :severity, :string
    field :summary, :string
    field :title, :string
    field :urgency, :string

    timestamps()
  end

  @doc false
  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:identifier, :title, :summary, :event, :effective, :expires, :urgency, :severity, :certainty, :areaDesc, :description, :instruction])
    |> validate_required([:identifier, :title, :summary, :event, :effective, :expires, :urgency, :severity, :certainty, :areaDesc, :description, :instruction])
    |> unique_constraint(:identifier)
  end
end
