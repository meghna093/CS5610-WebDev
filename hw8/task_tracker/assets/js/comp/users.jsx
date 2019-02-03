import React from 'react';
import {Link} from 'react-router-dom';

export default function Users(params) {
  let users = _.map(params.users, (uu) => 
              <User key={uu.id} user={uu} />);
  return <div><h2>Users</h2>
    <table className="table table-bordered">
      <thead><tr><th>Id</th>
                 <th>Name</th>
             </tr>
      </thead>
      <tbody>{users}</tbody>
    </table>
  </div>
}

function User(params) {
  return <tr>
      <td>{params.user.id}</td>
      <td>{params.user.name}</td>
    </tr>;
}
