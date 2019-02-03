import React from 'react';
import { Input, Button } from 'reactstrap';
import { connect } from 'react-redux';
import api from '../api';

function SearchLocation(props) {

  function submit() {
    var $inputs = $('#search');
    var data = {};
    $inputs.each(function() {
      data[this.name] = $(this).val();
    });
    var place = data['name'].split(' ').join('+');
    var url = "https://maps.googleapis.com/maps/api/geocode/json?address="+ place +"&key=AIzaSyBn7f8R1_N3F-Dtz51cUyXt_BmMvkzrSDU";
    console.log("URL:", url);
    api.addLocation(url);
  }

  return (
    <div className="row">
      <Input name="name" type="text" id="search" placeholder="Search"
             className="col mx-3"/>
      <Button onClick={submit} outline color="info" className="mr-3">
        <i className="fa fa-plus"></i>
      </Button>
    </div>
  );
}

export default connect((state) => state)(SearchLocation);

