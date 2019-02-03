import React from 'react';
import api from 'js/api';
import {NavLink, Link, Redirect} from 'react-router-dom';
import {Form, Button, Input, FormGroup} from 'reactstrap';

export default function Tasks(params) {
  let tasks = _.map(params.tasks, (tt) => 
              <Task key={tt.id} task={tt} />);
  return (
    <div><h3>Task List</h3>
      <table className="table table-bordered">
        <thead><tr><th scope="col">Title</th>
                   <th scope="col">Description</th>
                   <th scope="col">AssignedTo</th>
                   <th scope="col">Time Taken</th>
                   <th scope="col">Status</th>
               </tr>
        </thead><tbody>{tasks}</tbody>
      </table>
    </div>
  );
}

function Task(params) {
  let completed = params.task.completed == "1" ? "completed" : "pending";
  return <tr><td>{params.task.title}</td>
             <td>{params.task.description}</td>
             <td>{params.task.user.name}</td>
             <td>{params.task.time}</td>
             <td>{completed}</td>   
         </tr>;
}
