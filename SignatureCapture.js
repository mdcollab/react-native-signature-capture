'use strict';

var React = require('react');

var {
  requireNativeComponent,
  DeviceEventEmitter,
  findNodeHandle,
  NativeModules,
  View
} = require('react-native');

var Component = requireNativeComponent('RSSignatureView', null);

var styles = {
  signatureBox: {
    flex: 1
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'stretch',
    backgroundColor: '#F5FCFF',
  }
};

var subscription;

var SignatureCapture = React.createClass({
  componentDidMount: function() {
    subscription = DeviceEventEmitter.addListener(
        'onSaveEvent',
        this.props.onSaveEvent
    );
  },

  componentWillUnmount: function() {
    subscription.remove();
  },

  getImageData(): Promise {
    let manager = NativeModules.RSSignatureViewManager;

    return new Promise((resolve, reject) => manager.getBase64ImageData(
      findNodeHandle(this.refs.nativeComponent),
      (err, data) => err? reject(err): resolve(data)
    ));
  },

  render: function() {
    return (
      <View style={styles.container}>
        <Component
          ref="nativeComponent"
          style={styles.signatureBox}
          rotateClockwise={this.props.rotateClockwise}
          square={this.props.square}
        />
      </View>
    )
  }
});

module.exports = SignatureCapture;
