import React from 'react';
import { connect } from 'react-redux';
import { Map, Marker, InfoWindow, GoogleApiWrapper } from 'google-maps-react';
import { geolocated } from 'react-geolocated';
import api from '../api';

class HomeMap extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      interval: null,
      showInfoWindow: false,
      activeMarker: null,
      selectedPlace: ''
    };
  }

  componentWillMount() {
    //poll for location every tenth of a second until found
    if (this.props.isGeolocationAvailable && this.props.isGeolocationEnabled) {
      let interval = setInterval(this.updateCurrentLocation.bind(this), 100);
      this.setState({interval: interval});
    } else {
      this.props.dispatch({
        type: 'ERROR_MSG',
        msg: 'Cannot get current location. Current location features will not be available.'
      });
    }
  }

  componentWillUnmount() {
    if (this.state.interval != null) {
      clearInterval(this.state.interval);
    }
  }

  updateCurrentLocation() {
    if (this.props.isGeolocationAvailable &&
        this.props.isGeolocationEnabled &&
        this.props.coords) {
      if (this.state.interval != null) {
        clearInterval(this.state.interval);
      }
      this.props.dispatch({
        type: 'UPDATE_CURRENT_LOCATION',
        data: {
          lat: this.props.coords.latitude,
          lng: this.props.coords.longitude
        }
      });
      api.getCurrentWeather(this.props.coords.latitude, this.props.coords.longitude);
    }
  }

  onMarkerClick(props, marker, e) {
    console.log(props);
    this.setState({
      selectedPlace: props.title,
      activeMarker: marker,
      showInfoWindow: true
    });
  }

  onMapClick(props) {
    if (this.state.showInfoWindow) {
      this.setState({
        activeMarker: null,
        showInfoWindow: false
      });
    }
  }

  render() {
    let onMarkerClick = this.onMarkerClick.bind(this);
    let savedLocations = _.map(this.props.savedLocations, (loc) => {
      return <Marker title={loc.description}
                     position={{lat: loc.lat, lng: loc.long}}
                     key={loc.id}
                     onClick={onMarkerClick} />;
    });

    return (
      <Map google={this.props.google}
           center={this.props.currentLocation}
           onReady={this.updateCurrentLocation.bind(this)}
           onClick={this.onMapClick.bind(this)}
           className="map">
        <Marker title="Current Location"
                position={this.props.currentLocation}
                onClick={onMarkerClick} />
        {savedLocations}
        <InfoWindow marker={this.state.activeMarker}
                    visible={this.state.showInfoWindow}>
          <div><h5 className="m-0">{this.state.selectedPlace}</h5></div>
        </InfoWindow>
      </Map>
    );
  }
}

export default connect((state) => state)(geolocated({
  positionOptions: {enableHighAccuracy: false},
  userDecisionTimeout: 5000,
})(GoogleApiWrapper({
  apiKey: 'AIzaSyBn7f8R1_N3F-Dtz51cUyXt_BmMvkzrSDU'
})(HomeMap)));
