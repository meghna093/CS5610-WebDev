import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import { Button, Card, CardHeader, Collapse, CardBody, Table } from 'reactstrap';
import Spinner from './spinner';
import HomeMap from './homemap';
import SearchLocation from './searchlocation';
import api from '../api';

function titleCase(str) {
  return str.toLowerCase()
    .split(' ')
    .map((word) => {
      return word.charAt(0).toUpperCase() + word.slice(1);
    })
    .join(' ');
}

class Home extends React.Component {

  constructor(props) {
    super(props);
    this.state = {editing: false};
    api.getSavedLocations();
  }

  toggleEdit() { this.setState({editing: !this.state.editing}); }

  render() {
    return (
      <div>
        <div className="bg-info text-white rounded m-3 p-3">
          <div className="row">
            <h2 className="col">Local Weather</h2>
          </div>
          {this.renderWeather()}
        </div>
        <div className="m-3">
          <div className="row">
            <div className="col-12 col-md-6" style={{height: "400px"}}>
              <HomeMap />
            </div>
            <div className="col-12 col-md-6">
              <div className="border border-info rounded ml-0 ml-md-3 p-3">
                <h3 className="d-inline-block">Alerts by Location</h3>
                <Button color="info" className="float-right"
                        onClick={this.toggleEdit.bind(this)}>
                  {this.state.editing ? "Done" : "Edit"}
                </Button>
                {this.renderForm()}
                {this.renderLocations()}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderForm() {
    return <SearchLocation />;
  }

  renderLocations() {
    let currentLoc = '';
    let savedLocs = '';
    let spinner = '';
    if (this.props.savedLocations && this.props.savedLocations.length > 0) {
      savedLocs = _.map(this.props.savedLocations, (loc) => {
        return <Location key={loc.id} loc={loc} editing={this.state.editing} />;
      });
    }
    if (this.props.currentLocation) {
      let data = {
        description: "Current Location",
        long: this.props.currentLocation.lng,
        lat: this.props.currentLocation.lat
      };
      currentLoc = <Location loc={data} editing={false} />;
    }
    if (!(currentLoc || savedLocs)) {
      spinner = <Spinner />;
    }

    return (
      <div>
        {currentLoc}
        {savedLocs}
        {spinner}
      </div>
    );
  }

  renderWeather() {
    if(!this.props.weather) {
      return <Spinner />;
    }
    let weather = this.props.weather;
    return (
      <Table className="w-100 text-center" responsive>
        <tbody>
          <tr>
            <td className="align-middle">
              <img src={"http://openweathermap.org/img/w/" + weather.weather[0].icon + ".png"} />
            </td>
            <td className="align-bottom">
              <h3>{weather.main.temp} F</h3>
            </td>
            <td className="align-bottom">
              <h3>{weather.main.temp_min} F</h3>
            </td>
            <td className="align-bottom">
              <h3>{weather.main.temp_max} F</h3>
            </td>
            <td className="align-bottom">
              <h3>{weather.wind.speed} mph</h3>
            </td>
            <td className="align-bottom">
              <h3>{weather.main.humidity}%</h3>
            </td>
          </tr>
          <tr>
            <td className="align-top">
              <small>{titleCase(weather.weather[0].description)}</small>
            </td>
            <td className="align-top">
              <small>Current Temperature</small>
            </td>
            <td className="align-top">
              <small>Low</small>
            </td>
            <td className="align-top">
              <small>High</small>
            </td>
            <td className="align-top">
              <small>Wind Speed</small>
            </td>
            <td className="align-top">
              <small>Humidity</small>
            </td>
          </tr>
        </tbody>
      </Table>
    );
  }
}

class Location extends React.Component {

  constructor(props) {
    super(props);
    this.state = {expanded: false, alerts: []}
  }

  toggle() {
    if (!this.state.expanded && this.state.alerts.length == 0) {
      api.getAlerts(
        {type: 'active_by_location',
         location_id: this.props.loc.id},
        ((alerts) => this.setState({alerts: alerts.reverse()})).bind(this)
      );
    }
    this.setState({expanded: !this.state.expanded});
  }

  deleteLocation() {
    api.deleteLocation(this.props.loc.id);
  }

  render() {
    let alerts = '';
    if (this.state.alerts.length == 0) {
      alerts = <Spinner />;
    } else {
      alerts = _.map(this.state.alerts, (a) => {
        return <Alert key={a.id} alertInfo={a} />;
      });
    }

    let button = '';
    if (this.props.editing) {
      button = (
        <span className="float-right btn-link text-warning"
              onClick={this.deleteLocation.bind(this)}>
          Delete
        </span>
      );
    } else {
      button = (
        <h4 className="float-right btn-link text-info m-0 pointer"
              onClick={this.toggle.bind(this)}>
          { this.state.expanded ?
            <i className="fa fa-chevron-up"></i> :
            <i className="fa fa-chevron-down"></i> }
        </h4>
      );
    }

    return (
      <Card className="mt-3">
        <CardHeader>
          <h5 className="m-0 d-inline-block truncated">
            {this.props.loc.description}
          </h5>
          {button}
        </CardHeader>
        <Collapse isOpen={this.state.expanded && !this.props.editing}>
          <CardBody>
            {alerts}
          </CardBody>
        </Collapse>
      </Card>
    );
  }
}

function Alert(params) {
  return (
    <div>
      <Link to={`/alert/${params.alertInfo.id}`} className="text-success">
        {params.alertInfo.title}
      </Link>
      <br/>
      <small>{params.alertInfo.instruction.substring(0,140)}</small>
      <hr/>
    </div>
  );
}

export default connect((state) => state)(Home);
