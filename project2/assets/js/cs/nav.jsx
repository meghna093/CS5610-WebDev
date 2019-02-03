import React from 'react';
import { NavLink } from 'react-router-dom';
import { NavItem, Navbar, Modal, ModalHeader, ModalBody, ModalFooter,
         Form, FormGroup, FormFeedback, Label, Input, Button,
         Collapse, NavbarToggler } from 'reactstrap';
import { connect } from 'react-redux';
import api from '../api';

class UserNav extends React.Component {

  constructor(props) {
    super(props);
    this.state = {settings: false, errors: {}, expanded: false};
  }

  toggle() { this.setState({expanded: !this.state.expanded}); }

  logOut() {
    this.props.dispatch({type: 'DELETE_USER'});
    this.props.dispatch({type: 'RESET_SUCCESS'});
    this.props.dispatch({type: 'RESET_ERROR'});
  }

  showSettings() {
    let user = this.props.user;
    this.props.dispatch({
      type: 'UPDATE_SETTINGS',
      data: {
        name: user.name,
        email: user.email,
        phone: user.phone,
        urgency: user.urgency,
        severity: user.severity,
        certainty: user.certainty,
        password: '',
        password_confirmation: ''
      }
    });
    this.setState({settings: true, errors: {}});
  }
  hideSettings() { this.setState({settings: false}); }

  feedback(field) {
    if (this.state.errors[field]) {
      return <FormFeedback>{this.state.errors[field][0]}</FormFeedback>;
    }
    return '';
  }

  update(ev) {
    let target = $(ev.target);
    let data = {};
    data[target.attr('name')] = target.val();
    this.props.dispatch({
      type: 'UPDATE_SETTINGS',
      data: data
    });
  }

  submitSettings() {
    api.submitSettings(
      this.props.user.user_id,
      this.props.settings,
      this.hideSettings.bind(this),
      ((errors) => this.setState({errors: errors})).bind(this)
    );
  }

  deleteAccount() {
    api.deleteAccount(this.props.user.user_id);
  }

  renderSettings() {
    let show = this.showSettings.bind(this);
    let hide = this.hideSettings.bind(this);
    let update = this.update.bind(this);
    return (
      <NavItem>
        <span onClick={show} color="link" className="nav-link pointer">
          Settings
        </span>
        <Modal isOpen={this.state.settings} toggle={hide}>
          <ModalHeader toggle={hide}>Account Settings</ModalHeader>
          <ModalBody>
            <Form>
              <h3>Notification Settings</h3>
              <FormGroup>
                <Label for="urgency">Alert Urgency</Label>
                <Input type="select" name="urgency" onChange={update}
                       value={this.props.settings.urgency}>
                  <option>Immediate</option>
                  <option>Expected</option>
                  <option>Future</option>
                  <option>Past</option>
                </Input>
                {this.feedback('urgency')}
              </FormGroup>
              <FormGroup>
                <Label for="severity">Alert Severity</Label>
                <Input type="select" name="severity" onChange={update}
                       value={this.props.settings.severity}>
                  <option>Extreme</option>
                  <option>Severe</option>
                  <option>Moderate</option>
                  <option>Minor</option>
                </Input>
                {this.feedback('severity')}
              </FormGroup>
              <FormGroup>
                <Label for="certainty">Alert Certainty</Label>
                <Input type="select" name="certainty" onChange={update}
                       value={this.props.settings.certainty}>
                  <option>Observed</option>
                  <option>Likely</option>
                  <option>Possible</option>
                  <option>Unlikely</option>
                </Input>
                {this.feedback('certainty')}
              </FormGroup>
              <hr/>
              <h3>User Settings</h3>
              <FormGroup>
                <Label for="name">Display Name:</Label>
                <Input type="text" name="name" placeholder="display name"
                       value={this.props.settings.name}
                       onChange={update} />
                {this.feedback('name')}
              </FormGroup>
              <FormGroup>
                <Label for="email">Email:</Label>
                <Input type="email" name="email" placeholder="user@example.com"
                       value={this.props.settings.email}
                       onChange={update} />
                {this.feedback('email')}
              </FormGroup>
              <FormGroup>
                <Label for="phone">Phone Number:</Label>
                <Input type="number" name="phone" placeholder="10-digit number"
                       min="1000000000" max="9999999999"
                       value={this.props.settings.phone}
                       onChange={update} />
                {this.feedback('phone')}
              </FormGroup>
              <FormGroup>
                <Label for="password">Password:</Label>
                <Input type="password" name="password" placeholder="password"
                       onChange={update} />
                {this.feedback('password')}
              </FormGroup>
              <FormGroup>
                <Label for="password_confirmation">Confirm Password:</Label>
                <Input type="password" name="password_confirmation"
                       placeholder="confirm password" onChange={update} />
                {this.feedback('password_confirmation')}
              </FormGroup>
              <hr/>
              <h3>Delete Account</h3>
              <Button onClick={this.deleteAccount.bind(this)}
                    color="warning">Delete Account</Button>
            </Form>
          </ModalBody>
          <ModalFooter>
            <Button onClick={hide} color="secondary">Cancel</Button>
            <Button onClick={this.submitSettings.bind(this)}
                    color="info">Submit</Button>
          </ModalFooter>
        </Modal>
      </NavItem>
    );
  }

  render() {
    return (
      <div className="ml-auto">
        <NavbarToggler onClick={this.toggle.bind(this)} />
        <Collapse isOpen={this.state.expanded} navbar>
          <nav className="navbar-nav">
            <NavItem>
              <span className="navbar-text text-warning">
                Hi, {this.props.user.name}!
              </span>
            </NavItem>
            {this.renderSettings()}
            <NavItem>
              <span onClick={this.logOut.bind(this)}
                    color="link" className="nav-link pointer">
                Log Out
              </span>
            </NavItem>
          </nav>
        </Collapse>
      </div>
    );
  }
}

let ConnectedUserNav = connect(({user, settings}) => {return {user, settings};})(UserNav);

function Nav(props) {
  let navRight = props.user ? <ConnectedUserNav /> : '';
  return (
    <Navbar color="light" light expand="sm" fixed="top">
      <NavLink className="navbar-brand" to="/home" exact={true}>
        <i className="far fa-comments"></i> StormChat
      </NavLink>
      { navRight }
    </Navbar>
  );
}

export default connect(({user}) => {return {user};})(Nav);
