import React from 'react';
import api from 'js/api';
import {Input} from 'reactstrap';
import {Redirect} from 'react-router-dom';
import {connect} from 'react-redux';

function stProp(state) {
  console.log("rerender@TaskForm", state);
  return {
    form: state.form,
    users: state.users,
  };
}

class Newtask extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      redirect: false
    }
    this.submit = this.submit.bind(this);
    this.update = this.update.bind(this);
    this.clear = this.clear.bind(this);
  }
  update(ev) {
    let target = $(ev.target);
    let data = {};
    data["user_id"] = this.props.user_id;
    if (target.attr('name') == "completed") {
      if ($(target).is(':checked')) {
        target.attr('value', 'true');
        data["completed"] = 'true';
      }
      else {
        target.attr('value', 'false');
        data["completed"] = 'false';
      }
    }
    else {
      data[target.attr('name')] = target.val();
    }
    let action = {
      type: 'UPDATE_FORM',
      data: data,
    };
    this.props.dispatch(action);
  }
  clear(ev) {
    this.props.dispatch({
      type: 'CLEAR_FORM',
    });
  }
  submit(ev) {
    api.submit_task(this.props.form);
    this.setState({redirect: true});
    this.props.dispatch({
      type: 'CLEAR_FORM',
    });
  }
  render() {
    const {from} = '/tasks';
    const {redirect} = this.state;
    let users = _.map(this.props.users, (uu) => <option key={uu.id} value={uu.id}>{uu.name}</option>);
    let meUser = _.filter(this.props.users, (uu) => this.props.user_id == uu.id);
    return (
      <div><form><h2>New Task</h2>
                   <div className="form-group">
                     <label>Title</label>
                     <input className="form-control" name="title" value={this.props.form.title} onChange={this.update} required/>
                   </div> 
                   <div className="form-group">
                     <label>Description</label>
                     <textarea className="form-control" name="description" value={this.props.form.description} rows="4" onChange={this.update} required></textarea>
                   </div>
                   <div className="form-group">
                     <label>AssignedTo(User ID)</label>
                     <input className="form-control" name="user_id" value={this.props.form.user_id} onChange={this.update} required/>
                   </div>
                   <button onClick={this.submit} className="btn btn-primary">Submit</button>
           </form>
           {redirect && ( <Redirect to={from || '/tasks'}/> )}
      </div>
    );
  }
}

export default connect(stProp)(Newtask);
