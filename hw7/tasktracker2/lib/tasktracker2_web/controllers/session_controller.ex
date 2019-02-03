defmodule Tasktracker2Web.SessionController do
use Tasktracker2Web, :controller
alias Tasktracker2.Accounts
alias Task.Accounts.User

def create(conn, %{"email" => email}) do
  user = Accounts.get_user_by_email(email)
  if user do
    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Welcome, #{user.name}")
    |> redirect(to: task_path(conn, :index))
  else
    conn
    |> put_flash(:error, "Login Failed, please register first")
    |> redirect(to: page_path(conn, :index))
  end
end

def delete(conn, _params) do
  conn
  |> delete_session(:user_id)
  |> put_flash(:info, "Logged out")
  |> redirect(to: page_path(conn, :index))
end
end