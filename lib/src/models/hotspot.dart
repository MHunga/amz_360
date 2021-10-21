import 'package:amz_360/src/view/hotspot_button.dart';
import 'package:amz_360/src/view/menu_control.dart';
import 'package:flutter/material.dart';

class Hotspot {
  Hotspot(
      {this.id,
      this.idImage,
      this.title,
      this.description,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.orgin = const Offset(0.5, 0.5),
      this.callbackMovement,
      required this.icon}) {
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

  /// The initial latitude, in degrees, between -90 and 90.
  final double latitude;

  /// The initial longitude, in degrees, between -180 and 180.
  final double longitude;

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
      callbackMovement: (idImage) {
        callbackMovement?.call(idImage, latitude, longitude);
      },
    );
  }
}
