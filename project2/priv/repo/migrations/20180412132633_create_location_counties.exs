defmodule Stormchat.Repo.Migrations.CreateLocationCounties do
  use Ecto.Migration

  def change do
    create table(:location_counties) do
      add :fips_code, :string, null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:location_counties, [:fips_code])
    create index(:location_counties, [:location_id])
  end
end
