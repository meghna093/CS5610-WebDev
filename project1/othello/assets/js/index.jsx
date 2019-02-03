import React from 'react';
import ReactDOM from 'react-dom';
import Logo from './components/symbol.js';

export default function run_index(root) {
  ReactDOM.render(<Index />, root);
}

class Index extends React.Component {
  constructor(props) {
    super(props);
    this.state = { name: null, }
    this.handleChange = this.handleChange.bind(this);}
  handleChange(e) {
    this.setState({ name: e.target.value, });
  }
  render() {
    let link = '/';
    if(this.state.name) { link = '/game/'+this.state.name;}
    return (<div id="home">
              <header><h1>Welcome to Othello!!</h1></header>
                <button className="btn" 
                      onClick={function(e) { e.preventDefault();
                                             if ($('.gmIn div').hasClass('active')) {
                                               $('.gmIn div').removeClass('active');
                                             }
                                             else {$('.gmIn div').addClass('active');}}}>
               <span>Start/Join</span>
             </button>
           <form className="gmIn" onSubmit={function(e) { e.preventDefault();
                                                          window.location=link;}}>
             <div className="input">
               <input onKeyUp={this.handleChange} placeholder={'Enter room name'}/>
               <button id="enter" type="submit" color='success'>Join</button>
             </div>
           </form>
           <div><button className="btn" onClick={function(e) { e.preventDefault();
                                                               window.location = "/lobby";}}>
                  <span>Game Room</span>
                </button>
           </div>
         <Logo/>
         </div>);
  }
}
