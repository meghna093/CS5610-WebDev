import store from './store';

const weatherAPI = "ae122e8192b014da71c80636464532d8";

function badToken(resp) {
  if (resp && resp.error && resp.error == 'TOKEN_UNAUTHORIZED') {
    store.dispatch({type: 'DELETE_USER'});
    store.dispatch({
      type: 'ERROR_MSG',
      msg: 'Session ended. Please log back in.'
    });
    return true;
  }
  return false;
}

class TheServer {

  constructor() {
    this.token = null;
    store.subscribe(this.listener.bind(this));
  }

  listener() {
    let state = store.getState();
    this.token = state.user ? state.user.token : null;
  }

  submitSignUp(data, onSuccess, onError) {
    $.ajax("/api/v1/users", {
      method: "post",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({ user_params: data }),
      success: (resp) => {
        store.dispatch({
          type: 'SUCCESS_MSG',
          msg: 'Signed up successfully'
        });
        onSuccess();
      },
      error: (resp) => {
        if (resp.status == 422) {
          onError(resp.responseJSON.errors);
        }
      }
    });
  }

  submitLogin(data, onSuccess) {
    $.ajax("/api/v1/token", {
      method: "post",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify(data),
      success: (resp) => {
        store.dispatch({
          type: 'SET_USER',
          user: resp
        });
        store.dispatch({
          type: 'SUCCESS_MSG',
          msg: `Welcome back, ${resp.name}!`
        });
        onSuccess();
      },
      error: (resp) => {
        store.dispatch({
          type: 'ERROR_MSG',
          msg: 'Login failed'
        });
      }
    });
  }

  submitSettings(userId, settings, onSuccess, onError) {
    let data = Object.assign({}, settings);
    if (!(data['password'] || data['password_confirmation'])) {
      if (data['password'])delete data['password'];
      delete data['password_confirmation'];
    }

    $.ajax(`/api/v1/users/${userId}`, {
      method: "put",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({
        token: this.token,
        user_params: data
      }),
      success: (resp) => {
        store.dispatch({
          type: 'SUCCESS_MSG',
          msg: 'Settings updated'
        });
        store.dispatch({
          type: 'UPDATE_USER',
          user: resp.data
        });
        onSuccess();
      },
      error: (resp) => {
        if (badToken(resp)) { return; }
        if (resp.status == 422) {
          onError(resp.responseJSON.errors);
        }
      }
    });
  }

  deleteAccount(userId) {
    $.ajax(`/api/v1/users/${userId}?token=${this.token}`, {
      method: "delete",
      success: (resp) => {
        store.dispatch({type: 'DELETE_USER'});
        store.dispatch({
          type: 'SUCCESS_MSG',
          msg: 'Account deleted successfully'
        });
      }, error: (resp) => {
        if (badToken(resp)) { return; }
      }
    });
  }

  getSavedLocations() {
    $.ajax(`/api/v1/locations?token=${this.token}`, {
      method: "get",
      success: (resp) => {
        store.dispatch({
          type: 'SAVED_LOCATIONS',
          data: resp.data
        });
      },
      error: (resp) => {
        if (badToken(resp)) { return; }
      }
    });
  }

  getCurrentWeather(lat, lon) {
    let path = "https://api.openweathermap.org/data/2.5/weather?" + `lat=${lat}&lon=${lon}&units=imperial&appid=${weatherAPI}`;
    $.ajax(path, {
      method: "get",
      success: (resp) => {
        store.dispatch({
          type: 'WEATHER',
          data: resp
        });
      }
    });
  }

  addLocation(url) {
    $.getJSON(url, (json) => {
      if(json['status'] == 'OK') {
        let name = json['results'][0]['formatted_address'];
        let lat_lng = json['results'][0]['geometry']['location'];
        $.ajax('/api/v1/locations', {
          method: 'post',
          dataType: "json",
          contentType: "application/json; charset=UTF-8",
          data: JSON.stringify({
            token: this.token,
            location: {
              lat: lat_lng.lat,
              long: lat_lng.lng,
              description: name
            }
          }),
          success: (resp) => {
            store.dispatch({
              type: 'ADD_LOCATION',
              data: resp.data
            });
            store.dispatch({
              type: 'SUCCESS_MSG',
              msg: `Successfully added ${name} to your saved locations`
            });
          },
          error: (resp) => {
            if (badToken(resp)) { return; }
            store.dispatch({
              type: 'ERROR_MSG',
              msg: 'Could not add location. Try entering an address, postal code, or city name.'
            });
          }
        });
      } else {
        store.dispatch({
          type: 'ERROR_MSG',
          msg: 'Could not find location. Try entering an address, postal code, or city name.'
        });
      }
    });
  }

  deleteLocation(loc_id) {
    $.ajax(`/api/v1/locations/${loc_id}?token=${this.token}`, {
      method: 'delete',
      success: (resp) => {
        store.dispatch({
          type: 'DELETE_LOCATION',
          id: loc_id
        });
        store.dispatch({
          type: 'SUCCESS_MSG',
          msg: 'Location deleted'
        });
      },
      error: (resp) => {
        if (badToken(resp)) { return; }
        store.dispatch({
          type: 'ERROR_MSG',
          msg: 'Could not delete location'
        });
        console.log(resp);
      }
    });
  }

  // type follows pattern (active|historical)_(older_)?by_(location|latlong)
  getAlerts(data, onSuccess) {
    data.token = this.token;
    let path = '/api/v1/alerts?' + _.map(data, (v, k) => `${k}=${v}`).join('&');
    $.ajax(path, {
      method: 'get',
      success: (resp) => {
        console.log(resp);
        onSuccess(resp.data);
      },
      error: (resp) => {
        if (badToken(resp)) { return; }
      }
    });
  }
}


export default new TheServer();
