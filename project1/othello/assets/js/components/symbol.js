import React, {PropTypes} from 'react';

export default class Symbol extends React.Component {
  render() {
    return (
      <img className="logo" style={{width: 300, justifyContent: 'center', alignItems: 'center'}} src="/images/symbol.png"/>);
  }
}
