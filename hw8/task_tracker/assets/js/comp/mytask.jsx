import React from 'react';
import {Form, Button, Input, FormGroup} from 'reactstrap';
import {NavLink, Link, Redirect} from 'react-router-dom';

export default function Mytasks(params) {
  let tasks = _.map(params.tasks, (tt) => 
              <Task key={tt.id} task={tt} />);
  return (
    <div><h2>My Tasks</h2>
           <table className="table table-bordered">
             <thead><tr><th scope="col">Title</th>
                        <th scope="col">Description</th>
                        <th scope="col">AssignedTo</th>
                        <th scope="col">TimeTaken</th>
                        <th scope="col">Status</th>
                        <th scope="col"></th>
                    </tr>
             </thead>
           <tbody>{tasks}</tbody>
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
             <td><Link to={"/tasks/" + params.task.id + "/edit"}>
                   <Button color="primary">Edit</Button></Link></td>
         </tr>;
}


