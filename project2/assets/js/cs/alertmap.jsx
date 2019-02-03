import React from 'react';
import { connect } from 'react-redux';
import { Polygon, Map, GoogleApiWrapper } from 'google-maps-react';

function AlertMap(props) {
  let polys = props.polygons;

  //Replace "poly" by this.props.polygons
  //Pass polygons from the parent calling function.
  let center = null;
  let polygons = polys.map((poly, i) => {
    let paths = poly[0].map((point) => {
      return {lat: Number(point.lat), lng: Number(point.lng)};
    });

    if (!center) { center = paths[0]; }

    return (
      <Polygon paths={paths}
               strokeColor="#0000FF"
               strokeOpacity={0.8}
               strokeWeight={2}
               fillColor="#0000FF"
               fillOpacity={0.35}
               key={i} />
    );
  });

  return (
    <Map google={props.google}
         className={'map'}
         center={center}
         zoom={6}>
      {polygons}
    </Map>
  );
}


export default GoogleApiWrapper({
  apiKey: 'AIzaSyBn7f8R1_N3F-Dtz51cUyXt_BmMvkzrSDU'
})(AlertMap);
