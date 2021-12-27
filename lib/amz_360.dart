export 'src/scene/scene_view.dart';
export 'src/view/amz_360_view.dart';
export 'src/models/response_vt_list_project.dart';
export 'src/models/response_vt_project.dart';

import 'dart:async';
import 'dart:io';

import 'package:amz_360/src/models/response_vt_list_project.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:amz_360/src/service/api_service.dart';

import 'src/models/vt_hotspot.dart';
import 'src/utils/utils.dart';

class Amz360 {
  static final Amz360 instance = Amz360();
  String? _apiKey;
  setClient(String apiKey) {
    _apiKey = apiKey;
  }

  final ApiService api = ApiService();
  int? currentImageId;
  final StreamController<VTHotspotLable> hotspotLableStreamController =
      StreamController.broadcast();

  Future<ResponseVtProject> getProject(
      {required int id, OnError? onError, OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.getProject(
          apikey: _apiKey!, id: id, onError: onError, onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  Future<ResponseVtListProject> getListProject(
      {OnError? onError, OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.getListProject(
          apiKey: _apiKey!, onError: onError, onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  // Create new project
  Future<ResponseVtProject> create(
      {required String title,
      String? descrition,
      required List<File> images,
      OnUploadProgressCallback? progressCallback,
      OnError? onError,
      OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.create(
          apiKey: _apiKey!,
          describe: descrition ?? "",
          images: images,
          title: title,
          progressCallback: progressCallback,
          onError: onError,
          onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  //
  Future<ResponseVtProject> updateProject(
      {required int idProject,
      String? title,
      String? description,
      OnError? onError,
      OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.updateProject(
          projectId: idProject,
          apiKey: _apiKey!,
          title: title,
          description: description,
          onError: onError,
          onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  //
  Future<ResponseVtProject> deleteProject(
      {required int id, OnError? onError, OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.deleteProject(
          apikey: _apiKey!, id: id, onError: onError, onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  Future addHotspotLable(
      {required int idImage,
      required String title,
      String? text,
      File? image,
      String? idVideoYoutube,
      required double x,
      required double y,
      OnError? onError,
      OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      final hotspot = await api.addHospotLable(
          apiKey: _apiKey!,
          imageId: idImage,
          title: title,
          x: Amz360Utils.shared.convertXtoServer(x, y),
          y: Amz360Utils.shared.convertYtoServer(y),
          z: Amz360Utils.shared.convertZtoServer(x, y),
          text: text,
          image: image,
          idYoutubeVideo: idVideoYoutube,
          onError: onError,
          onSuccess: onSuccess);
      hotspotLableStreamController.add(VTHotspotLable(
          x: x,
          y: y,
          id: hotspot.id,
          imageId: hotspot.imageId,
          title: hotspot.title,
          text: hotspot.text,
          imageUrl: hotspot.imageUrl,
          videoUrl: hotspot.videoUrl));
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  Future<bool> deleteHotspotLable(
      {required int imageId,
      required int hotspotId,
      OnError? onError,
      OnSuccess? onSuccess}) async {
    if (_apiKey != null) {
      return await api.deleteHotspotLable(
          apikey: _apiKey!,
          imageId: imageId,
          hotspotId: hotspotId,
          onError: onError,
          onSuccess: onSuccess);
    } else {
      throw Exception("Please set client with apikey");
    }
  }
}
