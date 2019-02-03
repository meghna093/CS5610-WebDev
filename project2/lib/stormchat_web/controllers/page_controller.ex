defmodule StormchatWeb.PageController do
  use StormchatWeb, :controller

  # render main log-in page
  def index(conn, _params) do
    render conn, "index.html"
  end
end
