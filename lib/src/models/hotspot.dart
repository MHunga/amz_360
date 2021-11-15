import 'package:amz_360/src/view/hotspot_button.dart';
import 'package:amz_360/src/view/menu_control.dart';
import 'package:flutter/material.dart';

class Hotspot {
  Hotspot(
      {this.id,
      this.isShowControl = true,
      this.idImage,
      this.title,
      this.description,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.z = 0.0,
      this.fromServer = true,
      this.orgin = const Offset(0.5, 0.5),
      this.callbackMovement,
      required this.icon}) {
    if (fromServer) {
      if (z > 0) {
        if (longitude > 0) {
          longitude = -(90 * (5000 - longitude) / 5000 + 5);
        } else {
          longitude = -(90 * (5000 - longitude) / 5000 - 5);
        }
      } else {
        if (longitude > 0) {
          longitude = 90 * (5000 - longitude) / 5000 + 5;
        } else {
          longitude = 90 * (5000 - longitude) / 5000 - 5;
        }
      }
      latitude = latitude * 180 / 5000;
    }

    widget = HotspotButton(
      icon: icon,
      title: title,
      descriptions: description,
      callbackMovement: (idImage) {
        callbackMovement?.call(idImage, latitude, longitude);
      },
    );
  }

  String? id;

  /// The name of this hotspot.
  String? title;

  int? idImage;

  /// The description of this hotspot
  String? description;

  /// From server , the value is between -5000 and 5000.
  double latitude;

  /// From server , the value is between -5000 and 5000.
  double longitude;

  /// Determine the position of the point in the positive or negative direction
  final double z;

  final bool fromServer;

  bool isShowControl;

  /// The local orgin of this hotspot. Default is Offset(0.5, 0.5).
  final Offset orgin;

  final ControlIcon icon;
  final Function(int, double, double)? callbackMovement;

  Widget? widget;

  changeInfo(String title, String description) {
    this.title = title;
    this.description = description;
    widget = HotspotButton(
      icon: icon,
      title: title,
      isShowControl: isShowControl,
      descriptions: description,
      callbackMovement: (idImage) {
        callbackMovement?.call(idImage, latitude, longitude);
      },
    );
  }

  addImage(int idImage) {
    this.idImage = idImage;
    widget = HotspotButton(
      icon: icon,
      idImage: idImage,
      isShowControl: isShowControl,
      callbackMovement: (idImage) {
        callbackMovement?.call(idImage, latitude, longitude);
      },
    );
  }

  showControlListenter(bool show) {
    widget = HotspotButton(
      icon: icon,
      idImage: idImage,
      isShowControl: show,
      callbackMovement: (idImage) {
        callbackMovement?.call(idImage, latitude, longitude);
      },
    );
  }
}
