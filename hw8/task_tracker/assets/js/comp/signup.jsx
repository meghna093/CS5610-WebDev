import React from 'react';
import api from 'js/api';
import {connect} from 'react-redux';
import {Link} from 'react-router-dom';
import {Redirect} from 'react-router'
import {Form, Input, Button, FormGroup} from 'reactstrap';

function state2props(state) {
  console.log("props@SignupForm", state);
  return {
    signup: state.signup,
  };
}

class Signup extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      redirect: false
    }
    this.clear = this.clear.bind(this);
    this.submit = this.submit.bind(this);
    this.update = this.update.bind(this);
  }
  update(ev) {
    let target = $(ev.target);
    let data = {};
    data[target.attr('name')] = target.val();
    let action = {
      type: 'UPDATE_SIGNUP_FORM',
      data: data,
    };
    this.props.dispatch(action);
  }
  clear(ev) {
    this.props.dispatch({
      type: 'CLEAR_SIGNUP_FORM',
    });
  }
  submit(ev) {
    api.submit_user(this.props.signup);
    this.props.dispatch({
      type: 'CLEAR_SIGNUP_FORM',
    });
    this.setState({ redirect: true });
  }
  render() {
    const {from} = '/';
    const {redirect} = this.state;
    return (
      <div><form><h2>Register</h2>
        <div className="form-group"><label>User Name</label>
          <input className="form-control" name="name" value={this.props.signup.name} onChange={this.update} required/>
        </div>
        <div className="form-group"><label>Email Address</label>
          <input className="form-control" name="email" type="email" value={this.props.signup.email} onChange={this.update} required/>
        </div>
        <div className="form-group"><label>Password</label>
           <Input type="password" name="password" placeholder="password" value={this.props.signup.password} onChange={this.update} required/>
        </div>
        <button onClick={this.submit} className="btn btn-primary">Register</button>
        <button onClick={this.clear} className="btn btn-primary">Clear</button>
        <p></p><Link to={"/"}>Home</Link>
      </form>
      {redirect && ( <Redirect to={from || '/'}/> )}
      </div>
    );
  }
}

export default connect(state2props)(Signup);
