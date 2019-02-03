import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { withRouter } from 'react-router';
import { Provider, connect } from 'react-redux';
import { Alert } from 'reactstrap';
import AuthRoute from './auth_route';
import Nav from './nav';
import Splash from './splash';
import Home from './home';
import Chat from './chat';

let Alerts = connect((state) => state)((props) => {
  let success = props.success ?
                <Alert color="success">{props.success}</Alert> :
                '';
  let error = props.error ?
              <Alert color="danger">{props.error}</Alert> :
              '';
  return (
    <div>
      {success}
      {error}
    </div>
  );
});

class StormChatCore extends React.Component {

  componentWillUpdate(nextProps, nextState) {
    if (this.props.location != nextProps.location) {
      if (nextProps.location.pathname != '/home') {
        this.props.dispatch({type: 'RESET_SUCCESS'});
      }
      this.props.dispatch({type: 'RESET_ERROR'});
      this.props.dispatch({type: 'RESET_FORMS'});
    }
  }

  render() {
    return (
      <div>
        <Nav />
        <div id="page-body" className="container-fluid">
          <Alerts />
          <Switch>
            <AuthRoute path="/home" exact={true} render={() => <Home />} />
            <AuthRoute path="/alert/:alert_id" exact={true}
                       render={({match}) => <Chat alert_id={match.params.alert_id} />} />
            <Route path="/" exact={true} render={() => <Splash />} />
          </Switch>
        </div>
      </div>
    );
  }
}

let ConnectedCore = withRouter(connect((state) => state)(StormChatCore));

let StormChat = connect((state) => state)((props) => {
  return (<Router><ConnectedCore /></Router>);
});

export default function stormchat_init(store) {
  let root = document.getElementById('root');
  ReactDOM.render(<Provider store={store}><StormChat /></Provider>, root);
}
