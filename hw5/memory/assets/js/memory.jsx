import React from 'react';
import ReactDOM from 'react-dom';
import {Button} from 'reactstrap';

export default function run_memory(root, channel) {
    ReactDOM.render(<Memory channel={channel} />, root);
}

function Card(props){
let cd = props.content;
if (cd.state=='0'){return <div className='col-3'><div className='block' onClick={()=>props.select(props.number)}></div></div>;}
else if(cd.state=='1'){return <div className='col-3'><div className='block click'><span>{cd.name}</span></div></div>;}
else{return <div className='col-3'><div className='block succ'><span>{cd.name}</span></div></div>;}}

class Memory extends React.Component{

render(){
let current_state = this;
let crdls = this.state.cards.map(function(element, x){
return <Card content={element} select={current_state.select.bind(current_state)} number={x} k={x}/>;});
return(<div className='game-panel'><p>Number of clicks:{this.state.count}</p>
<div className='controls'><Button onClick={this.restart.bind(this)}>Restart</Button></div>
<div className='row'>{crdls}</div></div>);}

gotView(vw){
let current_state = this;
console.log("game", vw.game)
this.setState(vw.game)
if (vw.game.choosen.length == 2){
setTimeout(function(){current_state.channel.push("fin", {name: window.gameName}).receive("ok", current_state.gotView.bind(current_state))},1000);}}

constructor(props){
super(props);
this.state = {cards: [],selcards: [],counter: 0};
this.channel=props.channel;
this.channel.join().receive("ok", this.gotView.bind(this)).receive("error", resp => { console.log("Unable to join", resp) });}

select(x){this.channel.push("select", {index: x, name: window.gameName}).receive("ok", this.gotView.bind(this));}

restart(){this.channel.push("restart", {name: window.gameName}).receive("ok", this.gotView.bind(this));}
}

