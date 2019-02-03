import React from 'react';
import Login from "./login";
import {NavLink, Link, Redirect} from 'react-router-dom';
import {CookiesProvider} from 'react-cookie';
import api from '../api';
import {Form, Button, Input, FormGroup} from 'reactstrap';
import {connect} from 'react-redux';

function stProp(state) {
  return {
    token: state.token,
  };
}

function Nav(props) {
  let isLoggedIn = (props.token != null);
  const toggleVisible = isLoggedIn ? 'visible' : 'hidden';
  let style = {
    visibility: toggleVisible,
  };
  return <header><nav>
           <ul className="nav nav-pills pull-right">
             <li style={style}><NavLink to="/">Home Page</NavLink></li>
             <li style={style}><NavLink to="/users">Users</NavLink></li>
             <li style={style}><div className="dropdown">
                   <button className="btn btn-light dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Action</button>
                     <div className="dropdown-menu" aria-labelledby="dropdownMenuButton">
                       <NavLink to="/tasks" className="nav-link">Tasks List</NavLink>
                       <NavLink to="/newtask" className="nav-link">Create Task</NavLink>
                       <NavLink to="/mytasks" className="nav-link">My Tasks</NavLink>
                     </div>
                 </div></li>
                 <li><Login/></li>
             </ul>
           </nav>
         </header>;
}

export default connect(stProp)(Nav);

