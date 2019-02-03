defmodule Stormchat.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string, null: false
      add :urgency, :string, null: false, default: "Future"
      add :severity, :string, null: false, default: "Moderate"
      add :certainty, :string, null: false, default: "Possible"
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
