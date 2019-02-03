defmodule Othello.Game do
  use Agent

  def correctMove(colors, present, nxt, trgt) do
    if isBound(present, nxt) do
      case Enum.fetch(colors, nxt) do
        {:ok, elem} ->
          elem != 0 && elem != trgt
        _ -> false
      end
    else
      false
    end
  end 

  def startGame(playerName) do
    colors = for _ <- 1..64, do: 0
    %{colors: colors, turn: 0, players: [playerName], winner: nil, speculators: [], livePlayers: 1}
  end

  def collectGames do
    try do
      Agent.get(:games, &(&1))
    catch
      exit, _ ->
        {_, game} = Agent.start(fn -> %{} end, name: :games)
        %{}
    end
  end

  def enterGame(currentPlayerName, playerName) do
    games = collectGames
    activeGame = Map.get(games, currentPlayerName)
    if activeGame do
      if Kernel.length(activeGame.players) <= 1 do
        if Enum.member? activeGame.players, playerName do
          %{"state" => activeGame, 
            "msg" => playerName <> " has joined back", 
            "type" => "success"}
        else
          activeGame = %{activeGame | players: activeGame.players ++ [playerName], livePlayers: 2}
          colors = activeGame.colors 
                    |> List.update_at(27, fn _ -> 1 end)
                    |> List.update_at(28, fn _ -> 2 end)
                    |> List.update_at(35, fn _ -> 2 end)
                    |> List.update_at(36, fn _ -> 1 end)
          activeGame = %{activeGame | colors: colors}
          startGames = %{games | currentPlayerName => activeGame}
          :ok = Agent.update(:games, fn last -> startGames end)
          %{"state" => activeGame, 
            "msg" => playerName <> " has joined the current game", 
            "type" => "success"}
        end
      else
        if Enum.member? activeGame.players, playerName do
          activeGame = %{activeGame | livePlayers: 2}
          startGames = %{games | currentPlayerName => activeGame}
          :ok = Agent.update(:games, fn last -> startGames end)
          %{"state" => activeGame, 
            "msg" => playerName <> " has joined back", 
            "type" => "success"}
        else
          if String.length(playerName) > 0 do
            if Enum.member? activeGame.speculators, playerName do
                %{"state" => activeGame, 
                  "msg" => playerName <> " is watching the current game", 
                  "type" => "info"}
            else
              activeGame = %{activeGame | speculators: activeGame.speculators ++ [playerName]} 
              startGames = %{games | currentPlayerName => activeGame}
              :ok = Agent.update(:games, fn last -> startGames end)
              %{"state" => activeGame, 
                "msg" => playerName <> " is watching the current game", 
                "type" => "info"}
            end
          else
              %{"state" => activeGame, 
                "msg" => "Name unknown, watching current game", "type" => "info"}
          end 
        end
      end
    else
      startGames = Map.put(games, currentPlayerName, startGame(playerName))
      :ok = Agent.update(:games, fn last -> startGames end)
      %{"state" => startGame(playerName), 
        "msg" => playerName <> " has joined the current game", 
        "type" => "success"}
    end
  end

  def nextStatus(currentPlayerName, index) do
    activeGame = currentStatus(currentPlayerName)
    colors = activeGame.colors
    resp = %{"state" => activeGame}
    player = activeGame.turn+1 
    case changeColors(colors, player, index) do
      {true, presentColor} -> {true, resp 
                                |> turnWin(presentColor)
                                |> changeStatus(currentPlayerName)}
      _ -> {false, activeGame}
    end
  end

  def currentStatus(currentPlayerName) do
    collectGames |> Map.get(currentPlayerName)
  end

  def changeStatus(resp, currentPlayerName) do
    games = collectGames
    startGames = %{games | currentPlayerName => resp["state"]}
    :ok = Agent.update(:games, fn last -> startGames end)
    resp
  end

  def removeStatus(currentPlayerName) do
    games = collectGames
    startGames = Map.delete games, currentPlayerName
    Agent.update(:games, fn last -> startGames end)
  end

  def changeColors(colors, player, index) do
    {:ok, color} = Enum.fetch(colors, index)
    if color > 0 do
      {false, colors}
    else
      {false, colors} 
        |> asstChangeColors(index, 1, player)
        |> asstChangeColors(index, 8, player)
        |> asstChangeColors(index, -1, player)
        |> asstChangeColors(index, -8, player)
        |> asstChangeColors(index, -9, player)
        |> asstChangeColors(index, -7, player)
        |> asstChangeColors(index, 9, player)
        |> asstChangeColors(index, 7, player)
    end
  end

  def swap(colors, begg, inc, trgt) do
    nxt = begg + inc
    if !isBound(begg, nxt) do
      {false, colors}
    else
      {:ok, nxtColor} = Enum.fetch(colors, nxt)
      if nxtColor == 0 do
        {false, colors}
      else
        if nxtColor == trgt do 
          {true, colors}
        else
          {res, nxtColor} = swap(colors, nxt, inc, trgt)
          if res do
            {true, List.update_at(nxtColor, nxt, fn _ -> trgt end)}
          else
            {false, colors}
          end
        end
      end
    end
  end

  def asstChangeColors(final, index, inc, player) do
    {finalResult, finalColor} = final
    if correctMove(finalColor, index, index+inc, player) do
      {presentResult, presentColor} = swap(finalColor, index, inc, player)
      if presentResult do
        {true, presentColor |> List.update_at(index, fn _ -> player end)}
      else
        final
      end
    else
      final
    end
  end

  def isBound(present, nxt) do
    nxt_i = div(nxt, 8)
    nxt_j = rem(nxt, 8)
    present_i = div(present, 8)
    present_j = rem(present, 8)
    different_i = (nxt_i - present_i)
    different_j = (nxt_j - present_j)
    nxt >= 0 && nxt < 64 && different_j >= -1 && different_j <= 1 && different_i >= -1 && different_i <= 1
  end 

  def winner(colors) do
    {zez, onz, twz} = fetchCount({0, 0, 0}, colors, 0)
    if zez == 0 do
      if onz > twz do 0 
      else
        if onz < twz do 1 
        else 2 
        end
      end
    else -1
    end
  end

  def exitGame(currentPlayerName, playerName) do
    game = currentStatus currentPlayerName
    if game && Enum.member? game.players, playerName do
      game = %{game | livePlayers: game.livePlayers - 1} 
      if game.livePlayers > 0 do
        resp = changeStatus(%{"state" => game}, currentPlayerName)
        %{"state" => resp["state"], 
          "msg" => playerName <> " (player) left", 
          "type" => "warning", "label" => "user:leave"}
      else
        :ok = removeStatus currentPlayerName
        %{"msg" => playerName <> " (last player) left, game room closed", 
          "type" => "warning", 
          "label" => "table:close"}
      end
    else
      if game && Enum.member? game.speculators, playerName do
        game = %{game | speculators: List.delete(game.speculators, playerName)}
        resp = changeStatus(%{"state" => game}, currentPlayerName)
        %{"state" => resp["state"], 
          "msg" => playerName <> " left", 
          "type" => "info", "label" => "user:leave"}
      else
        %{"state" => game, 
          "msg" => "name unknown, left", 
          "type" => "info", 
          "label" => "user:leave"}
      end
    end
  end

  def plotNxt(colors, player, index) do
    if index >= 64 do false
    else
      {nxtFnd, currColor} = changeColors(colors, player, index)
      nxtFnd || plotNxt(colors, player, index+1)
    end
  end
 
  def fetchCount(cnt, colors, index) do
    if index >= 64 do cnt
    else
      {zez, onz, twz} = cnt
      {:ok, color} = Enum.fetch(colors, index)
      if color == 0 do fetchCount({zez+1, onz, twz}, colors, index+1)
      else
        if color == 1 do fetchCount({zez, onz+1, twz}, colors, index+1)
        else fetchCount({zez, onz, twz+1}, colors, index+1)
        end
      end
    end
  end

  def turnWin(resp, colors) do
    game = resp["state"]
    player = 1 - game.turn
    activeGame = %{game | colors: colors}
    winnr0 = winner colors
    if winnr0 >= 0 do
      %{resp | 
        "state" => %{activeGame | 
        winner: winnr0}}
    else
      if plotNxt(colors, player+1, 0) do
        %{resp | 
          "state" => %{activeGame | 
          turn: player}}
      else
        if !plotNxt(colors, game.turn+1, 0) do
          {zez, onz, twz} = fetchCount({0, 0, 0}, colors, 0)
          if onz > twz do
            %{resp | 
              "state" => %{activeGame | 
              winner: 0}} 
          else
            if onz < twz do
              %{resp | 
                "state" => %{activeGame | 
                winner: 1}} 
            else
              %{resp | 
                "state" => %{activeGame | 
                winner: 2}} 
            end
          end
        else
          {:ok, player_name} = Enum.fetch(game.players, game.turn)
          resp = %{resp | 
                   "state" => activeGame}
          Map.update(resp, "msg", "No moves, " <> player_name <> "'s turn", &(&1))
        end
      end
    end
  end

  def rstrtGame(currentPlayerName) do
    game = currentStatus currentPlayerName
    nxtGm = startGame ""
    nxtGm = %{nxtGm 
                    | players: game.players, 
                      speculators: game.speculators, 
                      livePlayers: game.livePlayers}
    nxtGm = %{nxtGm 
                    | colors: nxtGm.colors 
                    |> List.update_at(27, fn _ -> 2 end)
                    |> List.update_at(28, fn _ -> 1 end)
                    |> List.update_at(35, fn _ -> 1 end)
                    |> List.update_at(36, fn _ -> 2 end)}
    changeStatus %{"state" => nxtGm}, currentPlayerName  
  end
end
