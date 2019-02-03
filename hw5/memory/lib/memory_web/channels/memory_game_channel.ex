defmodule MemoryWeb.MemoryGameChannel do
use MemoryWeb, :channel
alias Memory.Backup
alias Memory.Game
  
def handle_in("fin", %{"name" => name}, socket) do
game = Game.fin(socket.assigns[name])
Memory.Backup.save(name, game)
socket = assign(socket, name, game)
{:reply, {:ok, %{"game" => game}}, socket}
end

def handle_in("restart", %{"name" => name}, socket) do
game = Game.beg()
Memory.Backup.save(name, game)
socket = assign(socket, name, game)
{:reply, {:ok, %{"game" => game}}, socket}
end

def handle_in("select", %{"index" => x, "name" => name }, socket) do
game = Game.select(socket.assigns[name],x)
Memory.Backup.save(name, game)
socket = assign(socket, name, game)
{:reply, {:ok, %{"game" => game}}, socket}
end

def join("memory_game:"<> name, payload, socket) do
if authorized?(payload) do
game = Memory.Backup.load(name) || Game.beg()
socket = assign(socket,name, game)
{:ok, %{"join" => name, "game" => game}, socket}
else {:error, %{reason: "unauthorized"}}
end
end

defp authorized?(_payload) do 
true
end
end
