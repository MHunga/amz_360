import 'package:amz_360/src/models/vt_hotspot.dart';

class ResponseVtProject {
  String? status;
  String? message;
  VTProject? data;

  ResponseVtProject({this.status, this.message, this.data});

  ResponseVtProject.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    message = json["message"];
    data = json["data"] == null ? null : VTProject.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = status;
    data["message"] = message;
    if (this.data != null) {
      data["data"] = this.data?.toJson();
    }
    return data;
  }
}

class VTProject {
  int? id;
  String? title;
  String? description;
  String? author;
  List<VTImage>? images;

  VTProject({this.id, this.title, this.description, this.author, this.images});

  VTProject.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    description = json["description"];
    author = json["author"];
    images = json["images"] == null
        ? null
        : (json["images"] as List).map((e) => VTImage.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["title"] = title;
    data["description"] = description;
    data["author"] = author;
    if (images != null) {
      data["images"] = images?.map((e) => e.toJson()).toList();
    }
    return data;
  }

  changeInfo({required String title, required String description}) {
    this.title = title;
    this.description = description;
  }
}

class VTImage {
  VTImageDetails? image;
  List<VTHotspotLable>? label;
  List<VTHotspotLink>? link;

  VTImage({this.image, this.label, this.link});

  VTImage.fromJson(Map<String, dynamic> json) {
    image =
        json["image"] == null ? null : VTImageDetails.fromJson(json["image"]);
    label = json["label"] == null
        ? null
        : (json["label"] as List)
            .map((e) => VTHotspotLable.fromJson(e))
            .toList();
    link = json["link"] == null
        ? null
        : (json["link"] as List).map((e) => VTHotspotLink.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (image != null) {
      data["image"] = image?.toJson();
    }
    if (label != null) {
      data["label"] = label?.map((e) => e.toJson()).toList();
    }
    if (link != null) {
      data["link"] = link?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class VTImageDetails {
  int? id;
  String? url;
  String? thumbnailUrl;

  VTImageDetails({this.id, this.url, this.thumbnailUrl});

  VTImageDetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json["url"];
    thumbnailUrl = json["thumbnail_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["url"] = url;
    data["thumbnail_url"] = thumbnailUrl;
    return data;
  }
}
