import React from 'react';
import { Circle } from 'react-konva';
import ReactDOM from 'react-dom';

export default class Ball extends React.Component {
  render() {
    const radius = 25;
    let index = this.props.index;
    let opacity = this.props.color == 0 ? 0 : 1;
    let images = this.props.images;
    let par = this.props.par;
    let onClick = null;
    let y = Math.floor(index/8)*radius*2+radius;
    let x = index%8*radius*2+radius;
    if(this.props.onClick) { onClick = () => {this.props.onClick(index, par);} }
    return (<Circle radius={radius-2} fillPatternImage={this.props.color == 1 ? images.black : images.white}
             fillPatternOffset={{x: x, y: y}} opacity={opacity} x={x} y={y} onClick={onClick}/>);
  }
}
