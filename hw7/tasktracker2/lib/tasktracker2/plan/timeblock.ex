defmodule Tasktracker2.Plan.Timeblock do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tasktracker2.Plan.Timeblock


  schema "timeblocks" do
    field :endTime, :integer
    field :startTime, :integer
    belongs_to :task, Tasktracker2.Plan.Task

    timestamps()
  end

  @doc false
  def changeset(%Timeblock{} = timeblock, attrs) do
    timeblock
    |> cast(attrs, [:startTime, :endTime, :task_id])
    |> validate_required([:startTime, :endTime, :task_id])
  end
end
