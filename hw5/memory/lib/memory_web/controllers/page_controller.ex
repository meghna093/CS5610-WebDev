defmodule MemoryWeb.PageController do
use MemoryWeb, :controller

def game(conn, _params) do
render conn, "game.html", game: _params["game"]
<<<<<<< HEAD
=======
end
def index(conn, _params) do
render conn, "index.html"
end
>>>>>>> 33c70ade111195ff54e93b4571a038612141f4f7
end
def index(conn, _params) do
render conn, "index.html"
end
end