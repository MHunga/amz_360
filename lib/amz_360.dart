export 'src/scene/scene_view.dart';
export 'src/view/amz_360_view.dart';
export 'src/view/menu_control.dart';
export 'src/models/response_vt_list_project.dart';
export 'src/models/response_vt_project.dart';

import 'dart:async';
import 'dart:io';

import 'package:amz_360/src/models/response_vt_list_project.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:amz_360/src/service/api_service.dart';
import 'package:amz_360/src/view/menu_control.dart';

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

  Future<ResponseVtProject> getProject(int id) async {
    if (_apiKey != null) {
      return await api.getProject(apikey: _apiKey!, id: id);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  Future<ResponseVtListProject> getListProject() async {
    if (_apiKey != null) {
      return await api.getListProject(apiKey: _apiKey!);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  // Create new project
  Future<ResponseVtProject> create(
      {required String title,
      String? descrition,
      required List<File> images,
      OnUploadProgressCallback? progressCallback}) async {
    if (_apiKey != null) {
      return await api.create(
          apiKey: _apiKey!,
          describe: descrition ?? "",
          images: images,
          title: title,
          progressCallback: progressCallback);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  //
  //edit() {}

  //
  Future<ResponseVtProject> deleteProject(int id) async {
    if (_apiKey != null) {
      return await api.deleteProject(apikey: _apiKey!, id: id);
    } else {
      throw Exception("Please set client with apikey");
    }
  }

  Future addHotspotLable({
    required int idImage,
    required String title,
    String? text,
    File? image,
    String? idVideoYoutube,
    required double x,
    required double y,
  }) async {
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
          idYoutubeVideo: idVideoYoutube);
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

  Future<bool> deleteHotspotLable(int imageId, int hotspotId) async {
    if (_apiKey != null) {
      return await api.deleteHotspotLable(
          apikey: _apiKey!, imageId: imageId, hotspotId: hotspotId);
    } else {
      throw Exception("Please set client with apikey");
    }
  }
}
