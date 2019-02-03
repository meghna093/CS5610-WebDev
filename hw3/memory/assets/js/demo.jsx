import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';
import classnames from 'classnames';

export default function run_demo(root) {
	  ReactDOM.render(<Demo side={0}/>, root);
}


class Demo extends React.Component{
	constructor(props){ 
		super(props);
		this.restart = this.restart.bind(this);
		this.gameScore = this.gameScore.bind(this);
		this.fetchCards = this.fetchCards.bind(this);
		this.mouseClicks = this.mouseClicks.bind(this);
		this.state = {cards:start(),previousCard:null,lockState:false,score:0,counter:0,};
	}


	mouseClicks(counter){
		if(!this.state.lockState){
			console.log(this.state.lockState);
			this.setState({counter:counter+1});}
		else{
			return;}}


	gameScore(num,ID){
		if(this.state.lockState){
			return;}
		var cards = this.state.cards;
		cards[ID].cardturned = true;
		this.setState({cards,lockState:true});
		if(this.state.previousCard){
			if(num === this.state.previousCard.num) {
				var score = this.state.score;
				cards[ID].cardselected = true;
				cards[this.state.previousCard.ID].cardselected = true;
				this.setState({cards,previousCard:null,lockState:false,score:score+1});}
			else{
				setTimeout(()=>{
					cards[ID].cardturned = false;
					cards[this.state.previousCard.ID].cardturned = false;
					this.setState({cards,previousCard:null,lockState:false});},1000);}}
		else{
			this.setState({previousCard:{ID,num},lockState:false,});}}


	fetchCards(cards){
		return cards.map((card,ind)=>{
			return(
				<Card primeKey={ind}
				num={card.num}
				cardturned={card.cardturned}
				ID={ind}
				gameScore={this.gameScore}
				cardselected={card.cardselected}
				counter={this.state.counter}
				mouseClicks={this.mouseClicks}/>);});}
	restart(){
		var toggle = start();
		this.setState({
			cards:toggle.map((a)=>[Math.random(),a]).sort((a,b)=>a[0]-b[0]).map((a)=>a[1]),
			previousCard:null,lockState:false,score:0,counter:0,});}


	render(){
		var restart = 'Restart';
		if(this.state.score === 8){
			restart = <div class="alert" >'Game won!  Restart'</div>;}
		return(<div>
			<div className = "board">{this.fetchCards(this.state.cards)}
			</div>
			<div>
			<p><b> Clicks:</b> {this.state.counter} 
			<b> Score:</b>{this.state.score}</p>
			<button onClick={this.restart} class="button">{restart}</button>
			</div>
			</div>);}}


class Card extends React.Component{
	constructor(props){
		super(props);
		this.cardOption=this.cardOption.bind(this);}

	cardOption(c){
		if(!this.props.cardturned){
			this.props.gameScore(this.props.num, this.props.ID);
			this.props.mouseClicks(this.props.counter);
		}}

	render(){
		var classes = classnames
		('Card',{'cardTurned':this.props.cardturned,},
			{'cardSelected':this.props.cardselected});
		var val = this.props.cardturned ? this.props.num:' ';
		return(<div className={classes} onClick={this.cardOption}>
			{val}
			</div>
		);}}


function start(){
	return[
		{num:'A'},{num:'B'},{num:'C'},{num:'D'},{num:'E'},{num:'F'},{num:'G'},{num:'H'},
		{num:'A'},{num:'B'},{num:'C'},{num:'D'},{num:'E'},{num:'F'},{num:'G'},{num:'H'},];}

