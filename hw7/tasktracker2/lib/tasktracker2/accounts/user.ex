defmodule Tasktracker2.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tasktracker2.Accounts.User

  schema "users" do
    field :email, :string
    field :name, :string
    belongs_to :mgr, User
    has_many :underlings, User, foreign_key: :mgr_id

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name, :mgr_id])
    |> validate_required([:email, :name])
  end
end
