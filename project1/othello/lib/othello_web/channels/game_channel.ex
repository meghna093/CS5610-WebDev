defmodule OthelloWeb.Gamechannel do
  use OthelloWeb, :channel
  alias Othello.Game

  def permission(_payload) do
    true
  end

  def finish(res, socket) do
    resp = Game.exitGame socket.assigns.currentPlayerName,          socket.assigns.current_user
    broadcast! socket, resp["label"], resp
    socket
  end

  def handle_in("restart", %{}, socket) do
    currentPlayerName = socket.assigns.currentPlayerName
    resp = Game.rstrtGame currentPlayerName
    broadcast! socket, "new:state", resp
    {:reply, {:ok, resp}, socket}
  end

  def join("gamechannel:" <> name, payload, socket) do
    if permission(payload) do
      current_user = socket.assigns.current_user
      currentPlayerName = name
      resp = Game.enterGame(currentPlayerName, current_user)
      socket = assign(socket, :currentPlayerName, currentPlayerName)
      send(self, {:after_join, resp})
      {:ok, %{"state" => resp["state"]}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, resp}, socket) do
    broadcast! socket, "new:user", resp
    {:noreply, socket}
  end

  def handle_in("move", %{"index" => i}, socket) do
    currentPlayerName = socket.assigns.currentPlayerName
    case Game.nextStatus(currentPlayerName, i) do
      {true, resp} ->
        broadcast! socket, "new:state", resp
        {:reply, {:ok, resp}, socket}
      {false, resp} ->
        {:reply, {:error, resp}, socket}
    end
  end
end
