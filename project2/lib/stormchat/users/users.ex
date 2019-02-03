defmodule Stormchat.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false

  alias Stormchat.Repo
  alias Stormchat.Users.User
  alias Stormchat.Alerts
  alias Stormchat.Alerts.County
  alias Stormchat.Locations.Location
  alias Stormchat.Locations.LocationCounty

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  # returns the number of users with saved locations affected by the given alert
  def get_affected_user_count(alert_id) do
    query =
      from u in User,
        join: l in Location, on: l.user_id == u.id,
        join: lc in LocationCounty, on: lc.location_id == l.id,
        join: c in County, on: c.fips_code == lc.fips_code,
        where: c.alert_id == ^alert_id,
        distinct: u.id

    users = Repo.all(query)

    Enum.count(users)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  # a method to get a user by his/her email address, which must be unique
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  # method to get a user by email with password authentication from Nat's Notes
  # http://www.ccs.neu.edu/home/ntuck/courses/2018/01/cs4550/notes/17-passwords/notes.html
  def get_and_auth_user(email, password) do
    user = get_user_by_email(email)

    if user == nil do
      nil
    else
      Comeonin.Argon2.check_pass(user, password)

      # case Comeonin.Argon2.check_pass(user, password) do
      #   {:ok, user} -> user
      #   _else       -> nil
      # end
    end
  end

  @doc """
  Creates a user and notifies Stormchat admins
  that their phone number needs to be verified with Twilio.
  Twilio provides access to an api that can be used to automate
  this verification process--but only with a paid Twilio account,
  which we deemed to be outside the scope of this process.
  Twilio's free account only allows SMS messaging to verified numbers,
  so we've implemented these admin notifications
  to help with the efficiency of this manual verification process.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    {msg, resp} = %User{}
    |> User.changeset(attrs)
    |> Repo.insert()

    case msg do
      :ok ->
        notify_admin(resp)
        {msg, resp}
      :error ->
        {msg, resp}
    end
  end

  # notify's Stormchat admins that a new/updated phone number must be verified
  def notify_admin(user) do
    body = "user (id:" <> Integer.to_string(user.id) <> ") needs phone number verified (" <> user.phone <> ")"
    Alerts.send_sms("8572721850", body)
    Alerts.send_sms("8578694172", body)
    Alerts.send_sms("6616458377", body)
    Alerts.send_sms("8573087731", body)
  end

  @doc """
  Updates a user and notifies admins if phone number has changed
  for the purpose of Twilio phone number verification.
  See doc for create_user above.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    {msg, resp} = user
    |> User.changeset(attrs)
    |> Repo.update()

    case msg do
      :ok ->
        if attrs["phone"] != user.phone do
          notify_admin(resp)
        end
        {msg, resp}
      :error ->
        {msg, resp}
    end

  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
