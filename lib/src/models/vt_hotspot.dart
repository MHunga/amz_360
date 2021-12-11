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
      print("$title [${_position!.x!}, ${_position!.y!}, ${_position!.z!}]");
      // if (_position!.z! > 0) {
      //   if (_position!.x! > 0) {
      //     x = -(90 * (5000 - _position!.x!) / 5000);
      //     x = x! + 60 * (95 - x!) / 360;
      //   } else {
      //     x = -(90 * (5000 - _position!.x!) / 5000);
      //     x = x! - 60 * (95 - x!) / 360;
      //   }
      // } else {
      //   if (_position!.x! > 0) {
      //     x = 90 * (5000 - _position!.x!) / 5000;
      //     x = x! + 60 * (95 - x!) / 360;
      //     print(x);
      //   } else {
      //     x = 90 * (5000 - _position!.x!) / 5000;
      //     x = x! - 60 * (95 - x!) / 360;
      //   }
      // }
      x = convertX(_position!.x!, _position!.z!);
      y = (_position!.y!) * 90 / 5000;
     // y = y! - 35 * y! / 90;
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

  double convertX(double px, double pz) {
    double x = 0.0;
    double z = 1;
    if(pz >0) z = -1;
    if (px < 4990 && px >= 4900) {
      x = recipe(0, px, 5000, 4900);
    }else if(px < 4900 && px >= 4680){
      x = recipe(10*z, px, 4900, 4680);
    }else if(px < 4680 && px>= 4240){
      x = recipe(20*z, px, 4680, 4240);
    }else if(px < 4240 && px >= 3750){
      x = recipe(30*z, px, 4240, 3750);
    }else if(px < 3750 && px >= 3180){
      x = recipe(40*z, px, 3750, 3180);
    }else if (px < 3180 && px >= 2400){
      x = recipe(50*z, px, 3180, 2400);
    }else if(px < 2400 && px>= 1600){
      x = recipe(60*z, px, 2400, 1600);
    }else if (px < 1600 && px >= 800){
      x = recipe(70*z, px, 1600, 800);
    }else if(px < 800 && px >= 0){
      x = recipe(80*z, px, 800, 0);
    }
    
    else if(px < 0 && px >= -800){
      x = recipe(90*z, px, 0 , -800);
    }else if (px < -800 && px >= -1600){
      x = recipe(100*z, px, -800, -1600);
    }else if(px < -1600 && px>= -2400){
      x = recipe(110*z, px, -1600, -2400);
    }else if(px < -2400 && px>= -3180){
      x = recipe(120*z, px, -2400, -3180);
    }else if(px < -3180 && px>= -3750){
      x = recipe(130*z, px, -3180, -3750);
    }else if(px < -3750 && px>= -4240){
      x = recipe(140*z, px, -3750, -4240);
    }else if(px < -4240 && px>= -4680){
      x = recipe(150*z, px, -4240, -4680);
    }else if(px < -4680 && px>= -4900){
      x = recipe(160*z, px, -4680, -4900);
    }else if(px < -4900 && px>= -5000){
      x = recipe(170*z, px, -4900, -5000);
    }
    if(pz >0) x = x* -1;
    return x;
  }

  double recipe(double start,double px, double from, double to){
    return (from -px) * 10 / (from - to) + start;
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
