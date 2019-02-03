defmodule Stormchat.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :lat, :float, null: false
      add :long, :float, null: false
      add :description, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:locations, [:lat, :long, :user_id])
    create index(:locations, [:user_id])
  end
end
