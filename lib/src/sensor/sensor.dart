import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

final AmzSensors amzSensors = AmzSensors();
const MethodChannel _methodChannel = MethodChannel('amz_sensors/method');
const EventChannel _orientationChannel =
    EventChannel('amz_sensors/orientation');

class OrientationEvent {
  OrientationEvent(this.yaw, this.pitch, this.roll);
  OrientationEvent.fromList(List<double> list)
      : yaw = list[0],
        pitch = list[1],
        roll = list[2];

  /// The yaw of the device in radians.
  final double yaw;

  /// The pitch of the device in radians.
  final double pitch;

  /// The roll of the device in radians.
  final double roll;
  @override
  String toString() => '[Orientation (yaw: $yaw, pitch: $pitch, roll: $roll)]';
}

class AbsoluteOrientationEvent {
  AbsoluteOrientationEvent(this.yaw, this.pitch, this.roll);
  AbsoluteOrientationEvent.fromList(List<double> list)
      : yaw = list[0],
        pitch = list[1],
        roll = list[2];

  /// The yaw of the device in radians.
  final double yaw;

  /// The pitch of the device in radians.
  final double pitch;

  /// The roll of the device in radians.
  final double roll;
  @override
  String toString() => '[Orientation (yaw: $yaw, pitch: $pitch, roll: $roll)]';
}

class ScreenOrientationEvent {
  ScreenOrientationEvent(this.angle);

  /// The screen's current orientation angle. The angle may be 0, 90, 180, -90 degrees
  final double? angle;

  @override
  String toString() => '[ScreenOrientation (angle: $angle)]';
}

class AmzSensors {
  Stream<OrientationEvent>? _orientationEvents;
  OrientationEvent? _initialOrientation;

  /// Change the update interval of sensor. The units are in microseconds.
  Future setSensorUpdateInterval(int interval) async {
    await _methodChannel
        .invokeMethod('setSensorUpdateInterval', {"interval": interval});
  }

  /// The update interval of orientation. The units are in microseconds.
  set orientationUpdateInterval(int interval) =>
      setSensorUpdateInterval(interval);

  /// The current orientation of the device.
  Stream<OrientationEvent> get orientation {
    _orientationEvents ??=
        _orientationChannel.receiveBroadcastStream().map((dynamic event) {
      var orientation = OrientationEvent.fromList(event.cast<double>());
      _initialOrientation ??= orientation;
      // Change the initial yaw of the orientation to zero
      var yaw = (orientation.yaw + math.pi - _initialOrientation!.yaw) %
              (math.pi * 2) -
          math.pi;
      return OrientationEvent(yaw, orientation.pitch, orientation.roll);
    });
    return _orientationEvents!;
  }
}
