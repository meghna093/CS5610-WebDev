import React from 'react';
import { connect } from 'react-redux';
import { Button, Input, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';
import { Socket } from 'phoenix';
import Spinner from './spinner';
import AlertMap from './alertmap';
import api from '../api';

class Chat extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      detail: false,
      message: "",
      alert: {},
      polygons: [],
      user_count: 0,
      posts: []
    };
    this.socket = new Socket("/socket", {params: {token: this.props.user.token}});
    this.socket.connect();
    this.channel = this.socket.channel("alerts:" + this.props.alert_id, {});
    this.channel.on("new_post", this.newMessage.bind(this));
    this.channel.join()
      .receive("ok", this.gotAlert.bind(this))
      .receive("error", this.gotError.bind(this));
  }

  componentWillUnmount() {
    this.channel.leave();
    this.channel = null;
    this.socket = null;
  }

  gotAlert(alertInfo) {
    console.log("ALERT", alertInfo);
    alertInfo.posts = alertInfo.posts.reverse();
    this.setState(alertInfo);
    if (alertInfo.posts.length > 0) {
      console.log('adding handler');
      $(window).one('scroll', this.handleScroll.bind(this));
    }
    this.scrollToBottom();
  }

  handleScroll() {
    if ($('html').scrollTop() == 0) {
      console.log('handling');
      this.channel.push('older', {'oldest_id': this.state.posts[0].id})
        .receive("ok", ((msg) => {
          let posts = msg.posts.reverse();
          this.setState({posts: posts.concat(this.state.posts)});
          let spinner = $('.spinner')[0]
          this.scrollTo(spinner.offsetTop);
        }));
    }
    $(window).one('scroll', this.handleScroll.bind(this));
  }

  gotError(error) {
    this.props.dispatch({
      type: 'ERROR_MSG',
      msg: error.reason
    });
  }

  newMessage(msg) {
    this.setState({posts: this.state.posts.concat(msg.post)});
  }

  toggleDetail() { this.setState({detail: !this.state.detail}); }

  sendMessage() {
    this.props.dispatch({type: 'RESET_ERROR'});
    if (this.state.message) {
      this.channel.push('post', {'body': this.state.message})
        .receive("error", this.gotError.bind(this))
        .receive("ok", ((msg) => {
          console.log(msg);
          this.newMessage(msg);
          this.setState({message: ""});
          this.scrollToBottom();
        }).bind(this));
    }
  }

  updateMessage(ev) { this.setState({message: $(ev.target).val()}); }

  scrollToTop() { this.scrollTo(0); }

  scrollToBottom() { this.scrollTo($(document).height()); }

  scrollTo(n) {
    $('html, body').stop().animate({
      scrollTop: n
    }, 500);
  }

  render() {
    let messages = _.map(this.state.posts, (post) => {
      return <Message key={post.id}
                      message={post.body}
                      user={post.user}
                      timestamp={post.timestamp}
                      mine={post.user.id == this.props.user.user_id}/>;
    });

    return (
      <div id="chat">
        <div id="chat-messages" className="container">
          <div className="row mb-3"><Spinner /></div>
          {messages}
        </div>
        <div id="chat-footer" className="row p-3 bg-light">
          <div className="container">
            <div className="row">
              <Input name="chat-field"
                     type="text"
                     id="chat-field"
                     placeholder="Send a message..."
                     onChange={this.updateMessage.bind(this)}
                     value={this.state.message}
                     className="mx-3 col" />
              <Button onClick={this.sendMessage.bind(this)}
                      disabled={this.state.message == ""}
                      color="info" className="mr-3">
                Send
              </Button>
            </div>
          </div>
        </div>
        <div id="chat-buttons">
          <Button color="warning"
                  onClick={this.toggleDetail.bind(this)}>
            <i className="fa fa-info"></i>
          </Button>
          <Button color="warning" outline
                  className="bg-white"
                  onClick={this.scrollToTop.bind(this)}>
            <i className="fa fa-arrow-up"></i>
          </Button>
          <Button color="warning" outline
                  className="bg-white"
                  onClick={this.scrollToBottom.bind(this)}>
            <i className="fa fa-arrow-down"></i>
          </Button>
        </div>
        {this.renderDetails()}
      </div>
    );
  }

  renderDetails() {
    let toggle = this.toggleDetail.bind(this);
    let alertInfo = this.state.alert;
    return (
      <Modal isOpen={this.state.detail} toggle={toggle}>
        <ModalHeader toggle={toggle} className="text-warning">
          {alertInfo.event}
        </ModalHeader>
        <ModalBody>
          <h4>{alertInfo.title}</h4>
          <hr/>
          <h4><span className="text-info">Users Affected:</span> {this.state.user_count}</h4>
          <hr/>
          <h4 className="text-info">Categories</h4>
          <p>
            <strong>Urgency:</strong> {alertInfo.urgency}<br/>
            <strong>Severity:</strong> {alertInfo.severity}<br/>
            <strong>Certainty:</strong> {alertInfo.certainty}
          </p>
          <hr/>
          <h4 className="text-info">Areas Affected</h4>
          <p>{alertInfo.areaDesc}</p>
          <div className="row" style={{height: "400px"}}>
            <AlertMap polygons={this.state.polygons} />
          </div>
          <hr/>
          <h4 className="text-info">Description</h4>
          <p>{alertInfo.description}</p>
          <hr/>
          <h4 className="text-info">Instructions</h4>
          <p>{alertInfo.instruction}</p>
        </ModalBody>
        <ModalFooter>
          <Button onClick={toggle} color="info">Close</Button>
        </ModalFooter>
      </Modal>
    );
  }
}

function Message(params) {
  let color = params.mine ? "warning" : "info";
  let classes = `border border-${color} mb-3 text-secondary message`;
  if (params.mine) {
    classes += " my-message";
  }

  let timestamp = new Date(`${params.timestamp}Z`).toLocaleString();

  return (
    <div className="row">
      <div className="col">
        <div className={classes}>
          <p className="m-2">
            <strong className={`text-${color}`}>{params.user.name}</strong>
            <small className="float-right">{timestamp}</small>
            <br/>
            {params.message}
          </p>
        </div>
      </div>
    </div>
  );
}

export default connect((state) => state)(Chat);
