import React from 'react';
import { Redirect } from 'react-router-dom';
import { connect } from 'react-redux';
import { Jumbotron, Form, FormFeedback, FormGroup,
         Label, Input, Button, Col, Collapse } from 'reactstrap';
import api from '../api';

class Splash extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      state: 1,
      errors: {},
      redirect: false
    };
  }

  showAbout() {
    this.setState({state: 1});
    this.props.dispatch({
      type: 'RESET_FORMS'
    });
  }

  showLogin() { this.setState({state: 2}); }

  showSignUp() { this.setState({state: 3}); }

  update(ev, type) {
    let target = $(ev.target);
    let data = {};
    data[target.attr('name')] = target.val();
    this.props.dispatch({
      type: type,
      data: data
    });
  }

  updateLogin(ev) { this.update(ev, 'UPDATE_LOGIN'); }

  updateSignUp(ev) { this.update(ev, 'UPDATE_SIGNUP'); }

  submitLogin() {
    api.submitLogin(
      this.props.login,
      (() => {this.setState({redirect: true});}).bind(this)
    );
  }

  submitSignUp() {
    api.submitSignUp(
      this.props.signUp,
      this.showAbout.bind(this),
      ((fields) => {
        this.setState({errors: fields});
      }).bind(this)
    );
  }

  feedback(field) {
    if (this.state.errors[field]) {
      return <FormFeedback>{this.state.errors[field][0]}</FormFeedback>;
    }
    return '';
  }

  render() {
    if (this.state.redirect) {
      return <Redirect to={this.props.redirect ? this.props.redirect : "/home"} />;
    }

    let body = '';
    switch(this.state.state) {
      case 2: body = this.renderLogin(); break;
      case 3: body = this.renderSignUp(); break;
      default: body = this.renderButtons();
    }

    return (
      <div className="container-fluid">
        <Jumbotron>
          {this.renderAbout()}
          {this.state.state == 1 ? this.renderButtons() : ''}
          <Collapse isOpen={this.state.state != 1}>
            {this.state.state == 2 ? this.renderLogin() : ''}
            {this.state.state == 3 ? this.renderSignUp() : ''}
          </Collapse>
          <small className="float-right"><a className="text-muted" href="http://www.thunderbolttours.com/wordpress/wp-content/uploads/extreme-storms-lightning1.jpg"><u>Image Source</u></a></small>
        </Jumbotron>
      </div>
    );
  }

  renderAbout() {
    return (
      <div id="splash-about" className="fade-in">
        <h1 className="display-4">StormChat</h1>
        <p className="lead">Stay in the know about severe weather in the places you care about. With StormChat, you can be notified of new alerts and chat directly with other people in affected areas. Preparedness is better when the whole community is involved.</p>
        <br/>
      </div>
    );
  }

  renderButtons() {
    return (
      <div className="fade-in">
        <Button onClick={this.showLogin.bind(this)}
                color="info">
          Login
        </Button>
        <span> - OR - </span>
        <Button onClick={this.showSignUp.bind(this)}
                color="secondary">
          Sign Up
        </Button>
      </div>
    );
  }

  renderLogin() {
    let update = this.updateLogin.bind(this);
    return (
      <div id="splash-login" className="fade-in">
        <h2>Log In</h2>
        <Form>
          <FormGroup row>
            <Label for="email" sm={2}>Email:</Label>
            <Col sm={10}>
              <Input type="email" name="email" placeholder="user@example.com"
                     onChange={update} />
            </Col>
          </FormGroup>
          <FormGroup row>
            <Label for="password" sm={2}>Password:</Label>
            <Col sm={10}>
              <Input type="password" name="password" placeholder="password"
                     onChange={update} />
            </Col>
          </FormGroup>
          <FormGroup row>
            <Col>
              <Button onClick={this.submitLogin.bind(this)}
                      color="info" className="mr-3">Login</Button>
              <Button onClick={this.showAbout.bind(this)}
                      color="secondary">Back</Button>
            </Col>
          </FormGroup>
        </Form>
      </div>
    );
  }

  renderSignUp() {
    let update = this.updateSignUp.bind(this);
    return (
      <div id="splash-signup" className="fade-in">
        <h2>Sign Up</h2>
        <Form>
          <FormGroup row>
            <Label for="name" sm={3}>Display Name:</Label>
            <Col sm={9}>
              <Input type="text" name="name" placeholder="display name"
                     onChange={update} />
              {this.feedback('name')}
            </Col>
          </FormGroup>
          <FormGroup row>
            <Label for="email" sm={3}>Email:</Label>
            <Col sm={9}>
              <Input type="email" name="email" placeholder="user@example.com"
                     onChange={update} />
              {this.feedback('email')}
            </Col>
          </FormGroup>
          <FormGroup row>
            <Label for="phone" sm={3}>Phone Number:</Label>
            <Col sm={9}>
              <Input type="number" name="phone" placeholder="10-digit number"
                     min="1000000000" max="9999999999"
                     onChange={update} />
              {this.feedback('phone')}
            </Col>
          </FormGroup>
          <FormGroup row>
            <Label for="password" sm={3}>Password:</Label>
            <Col sm={9}>
              <Input type="password" name="password" placeholder="password"
                     onChange={update} />
              {this.feedback('password')}
            </Col>
          </FormGroup>
          <FormGroup row>
            <Label for="password_confirmation" sm={3}>Confirm Password:</Label>
            <Col sm={9}>
              <Input type="password" name="password_confirmation"
                     placeholder="confirm password" onChange={update} />
              {this.feedback('password_confirmation')}
            </Col>
          </FormGroup>
          <FormGroup row>
            <Col>
              <Button onClick={this.submitSignUp.bind(this)}
                      color="info" className="mr-3">Sign Up</Button>
              <Button onClick={this.showAbout.bind(this)}
                      color="secondary">Back</Button>
            </Col>
          </FormGroup>
        </Form>
      </div>
    );
  }
}

export default connect((state) => {return state;})(Splash);
