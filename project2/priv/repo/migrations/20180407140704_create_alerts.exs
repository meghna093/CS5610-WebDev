defmodule Stormchat.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
    create table(:alerts) do
      add :identifier, :string, null: false
      add :title, :string, null: false
      add :summary, :text, null: false
      add :event, :string, null: false
      add :effective, :utc_datetime, null: false
      add :expires, :utc_datetime, null: false
      add :urgency, :string, null: false
      add :severity, :string, null: false
      add :certainty, :string, null: false
      add :areaDesc, :text, null: false
      add :description, :text, null: false
      add :instruction, :text, null: false

      timestamps()
    end

    create unique_index(:alerts, [:identifier])
    create index(:alerts, [:effective])
    create index(:alerts, [:expires])
    create index(:alerts, [:urgency])
    create index(:alerts, [:severity])
    create index(:alerts, [:certainty])
  end
end
