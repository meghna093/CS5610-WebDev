defmodule Tasktracker.Plan.Assignment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tasktracker.Plan.Assignment


  schema "assignments" do
    belongs_to :task, Tasktracker.Plan.Task
    field :time, :integer
    belongs_to :user, Tasktracker.Accounts.User
    

    timestamps()
  end

  @doc false
  def changeset(%Assignment{} = assignment, attrs) do
    assignment
    |> cast(attrs, [:time, :user_id, :task_id])
    |> validate_required([:time, :user_id, :task_id])
  end
end
