import 'dart:async';

import 'package:flutter/services.dart';

class Vibrate {
  static const MethodChannel _channel = MethodChannel('amz_vibrate');

  /// Vibrate for 100ms on Android, and for the default time on iOS (about 500ms as well)
  static Future vibrate() => _channel.invokeMethod('vibrate');
}
