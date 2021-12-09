import 'package:amz_360/amz_360.dart';
import 'package:flutter/material.dart';

class VTHotspotLink {
  int? id;
  HotspotPosition? _positions;
  int? toImage;
  double? x;
  double? y;
  Widget? widget;

  VTHotspotLink({this.id, this.toImage, this.x = 0.0, this.y = 0.0});

  VTHotspotLink.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    _positions = json["positions"] == null
        ? null
        : HotspotPosition.fromJson(json["positions"]);
    toImage = json["to_image"];
    if (_positions != null) {
      if (_positions!.z! > 0) {
        if (_positions!.x! > 0) {
          x = -(90 * (5000 - _positions!.x!) / 5000 + 5);
        } else {
          x = -(90 * (5000 - _positions!.x!) / 5000 - 5);
        }
      } else {
        if (_positions!.x! > 0) {
          x = 90 * (5000 - _positions!.x!) / 5000 + 5;
        } else {
          x = 90 * (5000 - _positions!.x!) / 5000 - 5;
        }
      }
      y = _positions!.y! * 180 / 5000;
    } else {
      x = 0.0;
      y = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["to_image"] = toImage;
    return data;
  }
}

class VTHotspotLable {
  int? id;
  String? title;
  String? text;
  String? imageUrl;
  String? videoUrl;
  int? imageId;
  HotspotPosition? _position;
  double? x;
  double? y;
  ControlIcon? icon;

  VTHotspotLable(
      {this.id,
      this.title,
      this.text,
      this.imageUrl,
      this.videoUrl,
      this.imageId,
      this.x = 0,
      this.y = 0,
      this.icon});

  VTHotspotLable.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    text = json["text"];
    imageUrl = json["image_url"];
    videoUrl = json["video_url"];
    imageId = json["image_id"];
    _position = json["position"] == null
        ? null
        : HotspotPosition.fromJson(json["position"]);
    if (_position != null) {
      if (_position!.z! > 0) {
        if (_position!.x! > 0) {
          x = -(90 * (5000 - _position!.x!) / 5000 + 5);
        } else {
          x = -(90 * (5000 - _position!.x!) / 5000 - 5);
        }
      } else {
        if (_position!.x! > 0) {
          x = 90 * (5000 - _position!.x!) / 5000 + 5;
        } else {
          x = 90 * (5000 - _position!.x!) / 5000 - 5;
        }
      }
      y = _position!.y! * 180 / 5000;
    } else {
      x = 0.0;
      y = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["title"] = title;
    data["text"] = text;
    data["image_url"] = imageUrl;
    data["video_url"] = videoUrl;
    data["image_id"] = imageId;
    return data;
  }
}

class HotspotPosition {
  double? x;
  double? y;
  double? z;

  HotspotPosition({this.x, this.y, this.z});

  HotspotPosition.fromJson(Map<String, dynamic> json) {
    x = double.parse(json["x"].toString());
    y = double.parse(json["y"].toString());
    z = double.parse(json["z"].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["x"] = x.toString();
    data["y"] = y.toString();
    data["z"] = z.toString();
    return data;
  }
}
