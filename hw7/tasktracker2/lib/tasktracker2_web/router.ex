defmodule Tasktracker2Web.Router do
  use Tasktracker2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :get_current_user
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Tasktracker2Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    delete "/session", SessionController, :delete
    post "/session", SessionController, :create
    resources "/tasks", TaskController do
      get "/done", TaskController, :done, as: :done
    end
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", Tasktracker2Web do
    pipe_through :api
    resources "/timeblocks", TimeblockController, except: [:new, :edit]
  end

def get_current_user(conn, _params) do
    user_id = get_session(conn, :user_id)
    user = Tasktracker2.Accounts.get_user_by_id(user_id || -1)
    assign(conn, :current_user, user)
  end
end
