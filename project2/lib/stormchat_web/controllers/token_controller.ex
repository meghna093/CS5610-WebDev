defmodule StormchatWeb.TokenController do
  use StormchatWeb, :controller

  alias Stormchat.Users

  action_fallback StormchatWeb.FallbackController

  # creates a token for future authentication
  def create(conn, %{"email" => email, "password" => password}) do
    case Users.get_and_auth_user(email, password) do
      {:ok, user} ->
        token = Phoenix.Token.sign(conn, "auth token", user.id)
        conn
        |> put_status(:created)
        |> render("token.json", user: user, token: token)
      _error ->
        conn
        |> put_status(401)
        |> render("error.json")
    end
  end
end
