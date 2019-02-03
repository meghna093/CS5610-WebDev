defmodule Memory.Game do

def select(game, index) do
cards = game.cards
choosen = game.choosen
count = game.count
case length(choosen) do
0 -> %{cards: card(cards, index, 1), choosen: [index], count: count + 1}
1 -> [las|oth] = choosen 
{:ok, last} = Enum.fetch(cards, las) 
{:ok, present} = Enum.fetch(cards, index)
if present.name == last.name and las != index do
%{cards: cards|>card(index, 2)|>card(las, 2), choosen: [], count: count + 1}
else %{cards: card(cards,index, 1), choosen: [las,index], count: count + 1}
end
2 -> game
end
end

def beg do
%{cards: Enum.map(cardls(), fn(x) -> %{name: x,state: 0} end),choosen: [],count: 0}
end

def fin(game) do
cards = game.cards
choosen = game.choosen
count = game.count
if length(game.choosen) > 1 do
[indx|tl] = choosen
[indy|ee] = tl
%{cards: cards |> card(indx, 0) |> card(indy, 0),choosen: [],count: count}
else game
end
end

def card(cards, index, state) do
{:ok, cd} = Enum.fetch(cards, index)
new_card = %{name: cd.name, state: state}
List.replace_at(cards, index, new_card)
end

def cardls() do
["A","B","C","D","E","F","G","H"]
|>List.duplicate(2)
|>List.flatten()
|>Enum.shuffle()
end
end
