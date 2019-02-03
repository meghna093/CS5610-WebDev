import { createStore, combineReducers } from 'redux';
import deepFreeze from 'deep-freeze';

/*
 * state layout:
 * {
 *   user: {
 *     user_id: null,
 *     name: "",
 *     token: null
 *   },
 *   login: {
 *     email: "",
 *     password: ""
 *   },
 *   signUp: {
 *     name: "",
 *     phone: "",
 *     email: "",
 *     password: "",
 *     password_confirmation: ""
 *   },
 *   weather: null,
 *   chat: "",
 *   success: "",
 *   error: ""
 * }
 */

function user(state = null, action) {
  switch (action.type) {
    case 'SET_USER':
      return action.user;
    case 'DELETE_USER':
      return null;
    case 'UPDATE_USER':
      return Object.assign({}, state, action.user);
    default:
      return state;
  }
}

let emptySignUp = {
  name: "",
  email: "",
  phone: "",
  password: "",
  password_confirmation: ""
};

function signUp(state = emptySignUp, action) {
  switch (action.type) {
    case 'UPDATE_SIGNUP':
      return Object.assign({}, state, action.data);
    case 'RESET_FORMS':
      return emptySignUp;
    default:
      return state;
  }
}

let emptyLogin = {
  email: "",
  password: ""
};

function login(state = emptyLogin, action) {
  switch (action.type) {
    case 'UPDATE_LOGIN':
      return Object.assign({}, state, action.data);
    case 'RESET_FORMS':
      return emptyLogin;
    default:
      return state;
  }
}

let emptySettings = {
  name: "",
  email: "",
  phone: "",
  password: "",
  password_confirmation: "",
  urgency: "",
  severity: "",
  certainty: ""
}

function settings(state = emptySettings, action) {
  switch (action.type) {
    case 'UPDATE_SETTINGS':
      return Object.assign({}, state, action.data);
    case 'RESET_FORMS':
      return emptySettings;
    default:
      return state;
  }
}

function weather(state = null, action) {
  switch (action.type) {
    case 'WEATHER':
      return action.data;
    default:
      return state;
  }
}

function chat(state = "", action) {
  switch (action.type) {
    case 'UPDATE_CHAT':
      return action.chat;
    case 'RESET_FORMS':
      return "";
    default:
      return state;
  }
}

function currentLocation(state = {}, action) {
  switch (action.type) {
    case 'UPDATE_CURRENT_LOCATION':
      return action.data;
    default:
      return state;
  }
}

function savedLocations(state = [], action) {
  switch (action.type) {
    case 'SAVED_LOCATIONS':
      return action.data;
    case 'ADD_LOCATION':
      return state.concat(action.data);
    case 'DELETE_LOCATION':
      return state.filter((loc) => loc.id != action.id);
    default:
      return state;
  }
}

function success(state = "", action) {
  switch (action.type) {
    case 'SUCCESS_MSG':
      return action.msg;
    case 'ERROR_MSG':
      return "";
    case 'RESET_SUCCESS':
      return "";
    default:
      return state;
  }
}

function error(state = "", action) {
  switch (action.type) {
    case 'ERROR_MSG':
      return action.msg;
    case 'SUCCESS_MSG':
      return "";
    case 'RESET_ERROR':
      return "";
    default:
      return state;
  }
}

function redirect(state = "/home", action) {
  switch (action.type) {
    // only set redirect if we have a path, null means redirect has been used
    case 'SET_REDIRECT':
      return state ? action.path : state;
    case 'RESET_REDIRECT':
      return null;
    default:
      return state;
  }
}

function root_reducer(state0, action) {
  //console.log("state0", state0);
  let reducer = combineReducers({
    user, login, signUp, settings, weather, chat,
    currentLocation, savedLocations, success, error,
    redirect
  });
  let state1 = reducer(state0, action);
  //console.log("state1", state1)
    return deepFreeze(state1);
};

let store = createStore(root_reducer);
export default store;
