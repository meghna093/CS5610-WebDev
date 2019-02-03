import React, {Component} from 'react'

export default class Info extends React.Component {
  render() {
    let i = 0;
    let presentState = this.props.status.state;
    let turn = presentState.turn;
    let player_1 = presentState.players[0];
    let player_2 = presentState.players[1];
    let presentUser = presentState.players[turn];
    let speculators = presentState.speculators.map(speculator => { return (<p key={i++}>{speculator}</p>); });
    return (<div><div><p>Player 1:{player_1}</p>
                      <p>Player 2:{player_2}</p>
                 </div><div><p>Turn:{presentUser}{" turn to play"}</p></div>
                 <div><div><span>Viewers</span></div>
                           <ol>{speculators}</ol></div>
                 <div><div><button onClick={function(e) {
                                   e.preventDefault();
                                   window.location="/";}}>Leave Room</button>
                      </div>
                 </div>
            </div>)
  }
}
