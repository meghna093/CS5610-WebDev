import React from 'react';
import { Redirect, Route } from 'react-router-dom';
import { connect } from 'react-redux';

let AuthRoute = connect(({user, redirect}) => {return {user, redirect};})((props) => {
  if (props.user) {
    props.dispatch({type: 'RESET_REDIRECT'});
  } else {
    props.dispatch({
      type: 'SET_REDIRECT',
      path: props.location.pathname
    });
  }

  return (
    <Route path={props.path}
           render={
             props.user ?
             props.render :
             () => <Redirect to="/" />
           } />
  );
});

export default AuthRoute;
