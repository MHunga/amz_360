export 'src/scene/scene_view.dart';
export 'src/view/amz_360_view.dart';
export 'src/view/menu_control.dart';
export 'src/models/response_vt_list_project.dart';
export 'src/models/response_vt_project.dart';

import 'dart:io';

import 'package:amz_360/src/models/response_vt_list_project.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:amz_360/src/service/api_service.dart';

import 'src/models/vt_hotspot.dart';

class Amz360 {
  static final Amz360 instance = Amz360();
  String? _apiKey;
  setClient(String apiKey) {
    _apiKey = apiKey;
  }

  final ApiService api = ApiService();

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

  Future<VTHotspotLable> addHotspotLable(
      {required int imageId,
      required String title,
      required String text,
      required double x,
      required double y,
      required double z}) async {
    if (_apiKey != null) {
      return await api.addHospotLable(
        apiKey: _apiKey!,
        imageId: imageId,
        title: title,
        x: x,
        y: y,
        z: z,
        text: text,
        onSuccess: () {
          print("Done");
        },
      );
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
