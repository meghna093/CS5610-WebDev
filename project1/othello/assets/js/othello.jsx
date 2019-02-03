import React from 'react';
import Konva from 'konva';
import ReactDOM from 'react-dom';
import {Text, Line, Circle, Stage, Rect, Layer} from 'react-konva';
import Ball from './components/ball.jsx';
import {Button, Row, Container,  Label, Input, Col, FormGroup, Form} from 'reactstrap';
import Details from "./details.jsx";
import alrt from 'sweetalert';
import {NotificationContainer, NotificationManager} from 'react-notifications';


export default function run_othello(root, channel) {
  ReactDOM.render(<Othello channel={channel}/>, root);
}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    const channel = props.channel;
    this.state = {
      colors:[],
      speculators:[],
      players:[],
      images: {},
      turn: -1,
      lock: true,
      winner: null,}
    this.getPic.bind(this);
    this.getPic();
    channel.on("new:state", resp => this.changeView(resp));
    channel.on("new:user", resp => { this.changeView(resp);
                                     if(resp["type"] == "success") {NotificationManager.success(resp.msg, '');} 
                                     else if(resp["type"] == "info") {NotificationManager.info(resp.msg, '');}});
    channel.join().receive("ok", resp => this.changeView(resp)).receive("error", resp => { console.log("Not able to join", resp);});
    this.changeView.bind(this);
    this.move.bind(this);
  }
  getPic() {
    var i = 0;
    let base = '/images/base.png';
    let white = '/images/Wpawn.png';
    let black = '/images/Bpawn.png';
    var images = {};    
    images['black'] = new Image();
    images['white'] = new Image();
    images['base'] = new Image();
    images['black'].onload = () => {if(i++ >= 2) this.setState({images: images});}
    images['white'].onload = () => {if(i++ >= 2) this.setState({images: images});}
    images['base'].onload = () => { if(i++ >= 2) this.setState({images: images}); }
    images['base'].src = base;
    images['white'].src = white;
    images['black'].src = black;}

  move(index, ta) {
    console.log("Selected");
    ta.setState({
      lock: true,
    });
    ta.props.channel.push("move", {index: index}).receive("ok", resp => ta.changeView(resp)).receive("error", resp => {
                                       alrt("Wrong move!!");
                                       ta.setState({lock: false});});
  }
  changeView(resp) {
    console.log("Change State", resp);
    this.setState(resp.state);
    if(resp.state.winner != null) { if(resp.state.players[resp.state.winner] == window.userToken) {
                                      alrt("Game Over", resp.state.players[resp.state.winner]+", congratulations, you win");}
                                    else {
                                      alrt("Game Over", resp.state.players[~resp.state.winner + 2]+" sorry, try again");}
    }
    const players = this.state.players;
    const turn = this.state.turn
    if(resp.state.winner == null && window.userToken == players[turn]) { this.setState({lock: false});}
    if(!resp["type"] && resp.msg) { alert(resp.msg);
                                    alrt("Info", resp.msg + "", "info")}
  }
  
  render() {
    let lns = [];
    let i = 0;
    let label = window.gameName;
    const balls = this.state.colors.map(color => {return (<Ball key={i} color={color} onClick={this.state.lock ? null : this.move}
                                                                par={this} index={i++} images={this.state.images}/>);});

    for(var j = 1; j < 8; j++) {
      var xcord = (<Line key={j} points={[j*50, 0, j*50, 400]} stroke={'rgb(249, 208, 144)'}
                         stokeWidth={1} closed={true}/>);
      var ycord = (<Line key={j+7} points={[0, j*50, 400,j*50]} stroke={'rgb(249, 208, 144)'}
                         stokeWidth={1} closed={true}/>);
      lns.push(xcord);
      lns.push(ycord);
    }
    return (<div>
                 <header>
                    <h1>GameID: {label}</h1>
                 </header>
                 <div className={"row"}>

                     <div className={"col-3"}>
                         <Details status={this}/>
                     </div>
                     <div className={"col-6"} style={{paddingLeft: "80px"}}>
                           <Stage width={400} height={400}>
                            <Layer>
                                <Rect width={400} height={400} cornerRadius={8}
                                      fillPatternImage={this.state.images['base']} fillPatternScale={1}/>
                                      {lns}{balls}
                            </Layer>
                           </Stage>
                     </div>
                     <div className={"col-3"}>
                        <h4><NotificationContainer/></h4>
                     </div>
                 </div>
            </div>);
  }
}
