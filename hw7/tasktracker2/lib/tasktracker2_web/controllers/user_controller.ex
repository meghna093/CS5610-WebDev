defmodule Tasktracker2Web.UserController do
  use Tasktracker2Web, :controller

  alias Tasktracker2.Accounts
  alias Tasktracker2.Accounts.User
  alias Tasktracker2.Plan

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    usr_list = Accounts.get_id()
    usr_list = [0 | usr_list]
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, usr_list: usr_list)
  end

  def create(conn, %{"user" => user_params}) do
    if Map.get(user_params, "mgr_id") == "0" do
        user_params = Map.delete(user_params, "mgr_id")
    end
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User Created")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user_by_id!(id)
    tasks = Plan.get_assigned_tasks(id)
    render(conn, "show.html", user: user, tasks: tasks)
  end

  def edit(conn, %{"id" => id}) do
    usr_list = Accounts.get_id()
    usr_list = [0 | usr_list]
    user = Accounts.get_user_by_id!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset, usr_list: usr_list)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user_by_id!(id)
    
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User Updated")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user_by_id!(id)
    {:ok, _user} = Accounts.delete_user(user)
    
  conn
    |> put_flash(:info, "User Deleted")
    |> redirect(to: user_path(conn, :index))
  end
end
