import React from 'react';
import {connect} from 'react-redux';
import {Form, Input, Button, FormGroup} from 'reactstrap';
import api from 'js/api';
import {Cookies, withCookies} from 'react-cookie';
import {NavLink, Link, Redirect} from 'react-router-dom';

function stProp(state) {
  console.log(state.token);
  return {
    login: state.login,
    token: state.token,
    users: state.users,
  };
}

class Login extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      redirect: false
    }
    this.update = this.update.bind(this);
    this.delete_token = this.delete_token.bind(this);
    this.create_token = this.create_token.bind(this);
  }
  update(ev) {
    let target = $(ev.target);
    let data = {};
    data[target.attr('name')] = target.val();
    this.props.dispatch({
      type: 'UPDATE_LOGIN_FORM',
      data: data,
    });
  }
  componentDidUpdate(prevProps) {
    if(prevProps.token != this.props.token) {
      if(this.props.token) {
        this.props.cookies.set("token", this.props.token);
      } else {
                this.props.cookies.remove("token");
             }
      }
  }
  create_token(ev) {
    api.submit_login(this.props.login);
    this.props.dispatch({
      type: "CLEAR_LOGIN_FORM",
    });
  }
  get_current_user_name(users, user_id) {
    let user = "";
    _.map(users, (uu) => { if (uu.id == user_id) { user = uu; } })
    return user.name;
  }
  delete_token(ev) {
    this.props.dispatch({
      type: "DELETE_TOKEN",
    });
    this.setState({redirect: true});
    this.props.cookies.remove("token");
    setTimeout(function(){
        location.reload();
        location.reload();
    }, 2500);
  }
  render() {
    const {from} = '/';
    const {redirect} = this.state;
    if (this.props.token) {
      let user_name = this.get_current_user_name(this.props.users, this.props.token.user_id);
      return <div><h4>Welcome { user_name }<Button onClick={this.delete_token}>LogOut</Button></h4></div>;
    }
    else {
      return <div><div><Link to="/signup"> Register</Link></div><div><ul className="nav navbar-nav navbar-right">
                         <li className="dropdown"><a href="#" className="dropdown-toggle" data-toggle="dropdown"><b>Login</b> </a>
                           <ul className="dropdown-menu">
                             <li><div className="row"><div className="col">
                               <form className="form" role="form" method="post" action="login" id="login-nav">
                                 <div className="form-group"><label className="sr-only">Email</label>
                                   <Input type="text" name="email" placeholder="email" value={this.props.login.email} onChange={this.update}/></div>
                                 <div>
                                   <label>Password</label>
                                     <Input type="password" name="password" placeholder="password" value={this.props.login.password} onChange={this.update}/></div>
                                 <div>
                                   <Button className="btn btn-primary btn-block" onClick={this.create_token}>LogIn</Button>
                                 </div>
                               </form>
                         </div>
                         </div></li></ul></li></ul></div>
                         {redirect && ( <Redirect to={from || '/'}/> )}
             </div>;}
  }
}

export default connect(stProp)(withCookies(Login));
