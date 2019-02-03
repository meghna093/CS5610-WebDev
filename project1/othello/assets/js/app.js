// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import socket from "./socket.js";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import run_othello from "./othello.jsx";
import run_index from "./index.jsx";

function start() {
  let game = document.getElementById('game');
  let index = document.getElementById('index');
  if(game) {
    let channel = socket.channel("gamechannel:"+window.gameName, {});
    run_othello(game, channel);
  }
  if (index) {
    run_index(index);
  }
}

$(start);
