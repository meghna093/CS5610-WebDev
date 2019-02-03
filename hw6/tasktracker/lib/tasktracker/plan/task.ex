defmodule Tasktracker.Plan.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tasktracker.Plan.Task


  schema "tasks" do
    field :description, :string
    many_to_many :users, Tasktracker.Accounts.User, join_through: Tasktracker.Plan.Assignment
    field :title, :string
    
    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
