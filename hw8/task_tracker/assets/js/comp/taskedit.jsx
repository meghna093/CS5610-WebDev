import React from 'react';
import {Form,  Button, Input, FormGroup} from 'reactstrap';
import {connect} from 'react-redux';
import {Link} from 'react-router-dom';
import api from 'js/api';

function stProp(state) {
  console.log("rerender@TaskEdit", state);
  return {
    update_form: state.update_form,
  };
}

class Taskedit extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      redirect: false
    }
    this.submit = this.submit.bind(this);
    this.update = this.update.bind(this);
  }
  submit(ev) {
    if(this.props.update_form.time < 0 || this.props.update_form.time % 15 != 0) {
      alert('Enter Time Taken as a multiple of 15!');
      return;
    }
    api.update_task(this.props.update_form, this.props.update_id);
    this.setState({ redirect: true });
    this.props.dispatch({
      type: 'CLEAR_EDIT_FORM',
    });
  }
  update(ev) {
    let target = $(ev.target);
    let data = {};
    if (target.attr('name') == "completed") {
      if ($(target).is(':checked')) {
        target.attr('value', "1");
      }
      else {
        target.attr('value', "0");
      }
    }
    data[target.attr('name')] = target.val();
    let action = {
      type: 'UPDATE_UPDATE_FORM',
      data: data,
      task_id: this.props.update_id,
      tasks: this.props.tasks,
    };
    this.props.dispatch(action);
  }

  render() {
    let task = this.props.task;
    const {from} = '/mytasks';
    const {redirect} = this.state;
    return (
      <div><div><h4>Title</h4><p>{task.title}</p>
                <h4>Description</h4><p>{task.description}</p>
           </div>
        <form><div className="form-group">
                <label className="form-check-label">
                  <h4>Mark Complete</h4>
                </label><br />
                <input className="form-check-input" type="checkbox" name="completed" value={this.props.update_form.completed} onChange={this.update}/>
          </div>
          <div className="form-group">
            <label className="form-check-label">
              <h4>Time Taken</h4>
            </label>
            <Input className="form-control" type="number" step="15" min="0" name="time" value={this.props.update_form.time} onChange={this.update}/>
          </div>
          <button onClick={this.submit} className="btn btn-primary">Submit</button>
          <p></p><Link to={"/mytasks/"}>TaskPage</Link>
        </form>
        {redirect && ( <Redirect to={from || '/mytasks'}/> )}
      </div>
    );
  }
}

export default connect(stProp)(Taskedit);
