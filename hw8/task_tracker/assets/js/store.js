import { createStore, combineReducers } from 'redux';
import deepFreeze from 'deep-freeze';

function tasks(state = [], action) {
  switch (action.type) {
  case 'TASKS_LIST':
    return [...action.tasks];
  case 'UPDATE_TASK':
    let nxtTask = action.task;
    let indx = -1;
    let prTask = {};
    _.each(state, function(tt, index) {
      if (tt.id == action.task_id) { indx = index;
                                     prTask = tt;}
    })
    nxtTask.description = prevTask.description;
    nxtTask.title = prTask.title;
    let ns = _.filter(state, (tt) => tt.id != action.task_id);
    return [nxtTask, ...ns];
  case 'ADD_TASK':
    return [action.task, ...state];
  case 'DELETE_TASK':
    return _.filter(state, (tt) => tt.id != action.task_id);
  default:
    return state;
  }
}

function users(state = [], action) {
  switch (action.type) {
  case 'ADD_USER':
    return [action.user, ...state];
  case 'USERS_LIST':
    return [...action.users];
  default:
    return state;
  }
}

let empty_form = {
  time: "0",
  title: "",
  completed: "0",
  description: "",
  user_id: "",
};

let empty_login = {
  password: "",
  email: "",
};

let empty_edFrom = {
  time: "0",
  completed: "0",
}

let empty_suFrom = {
  email: "",
  password: "",
  name: "",
};

function form(state = empty_form, action) {
  switch (action.type) {
    case 'UPDATE_FORM':
      return Object.assign({}, state, action.data);
    case 'CLEAR_FORM':
      return empty_form;
    case 'SET_TOKEN':
      return Object.assign({}, state, action.token);
    default:
      return state;
  }
}

function update_form(state = empty_edFrom, action) {
  switch (action.type) {
    case 'CLEAR_EDIT_FORM':
      state = empty_edFrom;
      return state;
    case 'UPDATE_UPDATE_FORM':
      return Object.assign({}, state, action.data);
    default:
      return state;
  }
}

function token(state = null, action) {
  switch (action.type) {
    case 'DELETE_TOKEN':
      return null;
    case 'SET_TOKEN':
      return action.token ? action.token : state;
    default:
      return state;
  }
}

function signup(state = empty_suFrom, action) {
  switch (action.type) {
    case 'CLEAR_SIGNUP_FORM':
      state = empty_suFrom;
      return empty_suFrom;
    case 'UPDATE_SIGNUP_FORM':
      return Object.assign({}, state, action.data);
    default:
      return state;
  }
}

function login(state = empty_login, action) {
  switch (action.type) {
    case 'CLEAR_LOGIN_FORM':
      state = empty_login;
      return state;
    case 'UPDATE_LOGIN_FORM':
      return Object.assign({}, state, action.data);
    default:
      return state;
  }
}

function root_reducer(state0, action) {
  console.log("reducer", action);
  // {posts, users, form} is ES6 shorthand for
  // {posts: posts, users: users, form: form}
  let reducer = combineReducers({users, login, tasks,  token, update_form, form,  signup});
  let state1 = reducer(state0, action);
  console.log("state1", state1);
  return deepFreeze(state1);
};

let store = createStore(root_reducer);
export default store;
