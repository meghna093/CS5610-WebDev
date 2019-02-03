import React from 'react';
import ReactDOM from 'react-dom';
import {Button,Input} from 'reactstrap';

export default function run_main(root){
    ReactDOM.render(<Main />, root);}

class Main extends React.Component{
constructor(props){super(props);}

render(){
return(
<div><Input id="name" type="text"/>
<Button  onClick={this.start.bind(this)}>Start</Button></div>)}

start(props){
let gName = $("#name").val();
if (!gName) {alert('Enter Name')}
else {window.location = "/game/" + gName;}}}
