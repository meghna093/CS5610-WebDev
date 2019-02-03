defmodule Stormchat.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :phone, :string
    field :urgency, :string, default: "Future"
    field :severity, :string, default: "Moderate"
    field :certainty, :string, default: "Possible"

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone, :urgency, :severity, :certainty, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_password(:password)
    |> validate_phone(:phone)
    |> put_pass_hash()
    |> validate_required([:name, :email, :phone, :urgency, :severity, :certainty, :password_hash])
    |> unique_constraint(:email)
  end

  # validate the phone number using Changeset's validate_change method
  def validate_phone(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, phone ->
      case valid_phone?(phone) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # phone validation helper method
  def valid_phone?(phone) do
    if ten_digit_number?(phone) do
      {:ok, phone}
    else
      {:error, "The phone number must be a 10-digit number with no other characters"}
    end
  end

  def ten_digit_number?(phone) do
    list_of_characters = String.graphemes(phone)

    ten_digits = case Enum.count(list_of_characters) do
      10 -> true
      _ -> false
    end

    digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    case ten_digits do
      false -> false
      true ->
        Enum.reduce(list_of_characters, true, fn(cc, acc) -> (Enum.member?(digits, cc)) && acc end)
    end
  end

  # method to validate password from Comonin docs
  # https://hexdocs.pm/comeonin/Comeonin.Argon2.html
  def validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case valid_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # password validation helper method from Nat's Notes
  # http://www.ccs.neu.edu/home/ntuck/courses/2018/01/cs4550/notes/17-passwords/notes.html
  def valid_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end
  def valid_password?(_), do: {:error, "The password is too short"}

  # method to add password hash to the changeset from Nat's Notes
  # http://www.ccs.neu.edu/home/ntuck/courses/2018/01/cs4550/notes/17-passwords/notes.html
  def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end
  def put_pass_hash(changeset), do: changeset
end
