defmodule TaskTracker.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed, :string, default: "0", null: false
    field :time, :string, default: "0", null: false
    field :description, :string, null: false
    belongs_to :user, TaskTracker.Users.User
    field :title, :string, null: false
    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:completed, :time, :description, :user_id, :title])
    |> validate_required([:completed, :time, :description, :user_id, :title])
  end
end
