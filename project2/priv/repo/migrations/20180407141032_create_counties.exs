defmodule Stormchat.Repo.Migrations.CreateCounties do
  use Ecto.Migration

  def change do
    create table(:counties) do
      add :fips_code, :string, null: false
      add :alert_id, references(:alerts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:counties, [:fips_code])
    create index(:counties, [:alert_id])
  end
end
