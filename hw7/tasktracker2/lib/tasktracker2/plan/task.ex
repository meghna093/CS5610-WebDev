defmodule Tasktracker2.Plan.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tasktracker2.Plan.Task


  schema "tasks" do
    field :description, :string
    field :time, :integer
    field :title, :string
    belongs_to :crt, Tasktracker2.Accounts.User
    belongs_to :user, Tasktracker2.Accounts.User
    has_many :timeblocks ,Tasktracker2.Plan.Timeblock, foreign_key: :task_id 

    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:title, :description, :user_id, :crt_id, :time])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:crt_id)
    |> validate_required([:title, :description, :crt_id, :user_id])
  end
end
