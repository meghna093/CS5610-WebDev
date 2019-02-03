defmodule TasktrackerWeb.Router do
  use TasktrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :get_current_user
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TasktrackerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    # get "/user/:id", UserController, :id
resources "/users", UserController
get "/assignments/:task_id/new", AssignmentController, :new
resources "/tasks", TaskController
post "/assignments", AssignmentController, :create
post "/session", SessionController, :create 
get "/assignments/:id/edit", AssignmentController, :edit
put "/assignments", AssignmentController, :update
delete "/assignments/:id", AssignmentController, :delete
delete "/session", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", TasktrackerWeb do
  #   pipe_through :api
  # end
def get_current_user(conn, _params) do
user_id = get_session(conn, :user_id)
user = Tasktracker.Accounts.get_user!(user_id || -1)
assign(conn, :current_user, user)
end
end
