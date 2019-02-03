defmodule TaskTracker.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password])
    |> chkPsswd(:password)
    |> put_psswdhash()
    |> validate_required([:email, :name, :password_hash])
  end

  def put_psswdhash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end

  def chkPsswd(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password -> case crrtPsswd?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  def crrtPsswd?(password) when byte_size(password) > 5 do
    {:ok, password}
  end

  def put_psswdhash(changeset), do: changeset

  def crrtPsswd?(_) do
    {:error, "The password is too short"}
  end
end
