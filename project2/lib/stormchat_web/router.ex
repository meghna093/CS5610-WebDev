defmodule StormchatWeb.Router do
  use StormchatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", StormchatWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :update, :delete]
    resources "/alerts", AlertController, only: [:index]
    resources "/locations", LocationController, only: [:index, :create, :delete]
    post "/token", TokenController, :create
  end

  scope "/", StormchatWeb do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
