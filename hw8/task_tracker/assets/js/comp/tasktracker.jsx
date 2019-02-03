import React from 'react';
import {Switch, BrowserRouter as Router, Redirect, Route} from 'react-router-dom';
import ReactDOM from 'react-dom';
import CurTask from './newtask'
import ChangeTask from './taskedit'
import Tasks from './tasks'
import {Provider, connect} from 'react-redux';
import Users from './users'
import Nav from './nav'
import Register from './signup'
import {CookiesProvider, cookie, Cookies, withCookies} from 'react-cookie';
import Intasks from './mytask'

function filter(tasks, id) {
  let task = "";
  _.map(tasks, (tt) => { if (tt.id == id) { task = tt; } })
  return task;
}

class TaskTracker extends React.Component {
  constructor(props) {
    super(props);
  }
  componentWillMount() {
    let token = this.props.cookies.get('token');
    this.props.dispatch({
      type: "SET_TOKEN",
      token: token
    });
  }
  render() {
    let isLoggedIn = (this.props.token != null);
    if (isLoggedIn) {
      return <Router><div><Nav/>
                       <div><Route path="/" exact={true} render={() =>
                         <div className="jumbotron"><h1>Welcome to TaskTracker</h1></div>} />
                           <Route path="/users" exact={true} render={() => <Users users={this.props.users} />} />
                           <Route path="/tasks" exact={true} render={() => <Tasks tasks={this.props.tasks}/>} />
                           <Route path="/signup" exact={true} render={() => <Redirect to="/"></Redirect>} />
                           <Route path="/newtask" render={() => <CurTask user_id={this.props.token.user_id}/>} />
                           <Switch>
                             <Route path="/tasks/:task_id/edit" render={({match}) => <ChangeTask task={filter(this.props.tasks, match.params.task_id)} update_id={match.params.task_id}/>} />
                           </Switch>
                           <Route path="/mytasks" exact={true} render={() => <Intasks tasks={_.filter(this.props.tasks, (tt) => tt.user.id == this.props.token.user_id)} />} />

                         </div>
                       </div>
              </Router>
    }
    else {
      return <Router><div><Nav/>
                       <div><Route path="/" exact={true} render={() => <div className="jumbotron">
                         <h1>Welcome to TaskTracker</h1> </div>} />
                         <Route path="/users" exact={true} render={() => <Redirect to="/"></Redirect>} />
                         <Route path="/tasks" exact={true} render={() => <Redirect to="/"></Redirect>} />
                         <Route path="/signup" exact={true} render={() => <Register />} />
                         <Route path="/newtask" render={() => <Redirect to="/"></Redirect>} />
                         <Switch> 
                           <Route path="/tasks/:task_id/edit" render={({match}) => <Redirect to="/"></Redirect>} />
                         </Switch>
                         <Route path="/mytasks" exact={true} render={() => <Redirect to="/"></Redirect>} />
                       </div>
                     </div>
             </Router>
    }
  }
};

export default function tasktracker_init(store) {
  ReactDOM.render(
    <Provider store={store}><CookiesProvider>
      <Tasktracker state={store.getState()} />
    </CookiesProvider></Provider>,
    document.getElementById('root')
  );
}

let Tasktracker = withCookies(connect((state) => state)(TaskTracker));
