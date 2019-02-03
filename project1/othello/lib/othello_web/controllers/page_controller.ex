defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller
  alias Othello.Game

  def enter(conn, params) do
    render conn, "enter.html", game: params["game"]
  end

  def index(conn, params) do
    if params["info"] do
      render conn, "index.html", info: params["info"]
    else
      render conn, "index.html", info: nil
    end
  end

  def game(conn, params) do
    presentGame = Game.currentStatus params["game"]
    user_name = get_session(conn, :user_name)
    if presentGame do
      players = presentGame.players
      if Kernel.length(players) == 2 || user_name && String.length(user_name) > 0 do
        render conn, "game.html", game: params["game"]
      else
        render conn, "enter.html", game: params["game"]
      end
    else
      if user_name && String.length(user_name) > 0 do
        render conn, "game.html", game: params["game"]
      else
        render conn, "enter.html", game: params["game"]
      end
    end
  end

  def room(conn, _params) do
    games = Game.collectGames
    gameCnt = Kernel.length(Map.keys(games))
    if gameCnt == 0 do
      render conn, "index.html", info: "No games, create one"
    else
      render conn, "room.html", games: games, gameCnt: gameCnt
    end
  end
end
