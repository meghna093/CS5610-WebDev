defmodule TasktrackerWeb.SessionController do
use TasktrackerWeb, :controller
alias Tasktracker.Accounts.User
alias Tasktracker.Accounts

def delete(conn, _params) do
conn
|> delete_session(:user_id)
|> put_flash(:info, "Logged out")
|> redirect(to: page_path(conn, :index))
end

def create(conn, %{"email" => email}) do
user = Accounts.get_user_by_email(email)
if user do
conn
|> put_session(:user_id, user.id)
|> put_flash(:info, "Welcome, #{user.name}")
|> redirect(to: task_path(conn, :index))
else
conn
|> put_flash(:error, "login failed")
|> redirect(to: page_path(conn, :index))
end
end
end
