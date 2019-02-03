defmodule Tasktracker2.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :mgr_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
