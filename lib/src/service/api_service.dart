import 'dart:convert';
import 'dart:io';

import 'package:amz_360/src/models/response_vt_list_project.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:amz_360/src/models/vt_hotspot.dart';
import 'package:dio/dio.dart';

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);
typedef OnSuccess = void Function();
typedef OnError = void Function(int statusCode, String message);

class ApiService {
  final dio =
      Dio(BaseOptions(baseUrl: "https://api.modernbiztech.com/api/v1/app/"));

  Future<ResponseVtProject> create(
      {required String apiKey,
      required String title,
      required String describe,
      required List<File> images,
      OnUploadProgressCallback? progressCallback,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    final map = <String, dynamic>{};
    var multipartFile = [];
    for (var item in images) {
      multipartFile.add(await MultipartFile.fromFile(item.path));
    }
    map['title'] = title;
    map['describe'] = describe;
    map['img[]'] = multipartFile;
    var body = FormData.fromMap(map);
    try {
      final response = await dio.post("project/create?apikey=$apiKey",
          data: body, onSendProgress: progressCallback);
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<ResponseVtListProject> getListProject(
      {required String apiKey, OnSuccess? onSuccess, OnError? onError}) async {
    try {
      final response = await dio.get("project/index?apikey=$apiKey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtListProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> updateProject(
      {required String apiKey,
      required int projectId,
      String? title,
      String? description,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final map = <String, dynamic>{};

      map['action'] = "edit_infomation";
      map['title'] = title;
      map['describe'] = description;

      var body = FormData.fromMap(map);
      final response = await dio
          .post("project/update/$projectId?apikey=$apiKey", data: body);
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

Future<ResponseVtProject> addImageToProject(
      {required String apiKey,
      required int projectId,
      required List<File> images,
      OnUploadProgressCallback? progressCallback,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final map = <String, dynamic>{};
      var multipartFile = [];
      map['action'] = "add_image";
     for (var item in images) {
      multipartFile.add(await MultipartFile.fromFile(item.path));
    }
      var body = FormData.fromMap(map);
      final response = await dio
          .post("project/update/$projectId?apikey=$apiKey", data: body,onSendProgress: progressCallback);
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> deleteImageFromProject(
      {required String apiKey,
      required int projectId,
      required int imageId,
      OnUploadProgressCallback? progressCallback,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final map = <String, dynamic>{};
      map['action'] = "remove_image";
      map['image_id'] = imageId;
     
      var body = FormData.fromMap(map);
      final response = await dio
          .post("project/update/$projectId?apikey=$apiKey", data: body);
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> getProject(
      {required String apikey,
      required int id,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final response = await dio.get("project/$id?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> deleteProject(
      {required String apikey,
      required int id,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final response = await dio.get("project/delete/$id?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        return ResponseVtProject.fromJson(data);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<VTHotspotLable> addHospotLable(
      {required String apiKey,
      required int imageId,
      required String title,
      required double x,
      required double y,
      required double z,
      String? text,
      String? idYoutubeVideo,
      File? image,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['positions_x'] = x.toStringAsFixed(2);
    map['positions_y'] = y.toStringAsFixed(2);
    map['positions_z'] = z.toStringAsFixed(2);
    if (text != null) {
      map['text'] = text;
    }

    if (image != null) {
      map['img[]'] = [await MultipartFile.fromFile(image.path)];
    }

    if (idYoutubeVideo != null) {
      map['video_url'] =
          '<iframe width="560" height="315" src="https://www.youtube.com/embed/$idYoutubeVideo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
    }
    final body = FormData.fromMap(map);
    try {
      final response = await dio
          .post("image/$imageId/addinfospot?apikey=$apiKey", data: body);
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        if (onSuccess != null) onSuccess();
        data['data']['positions'] = {
          'x': data['positions_x'],
          'y': data['positions_y'],
          'z': data['positions_z'],
        };
        return VTHotspotLable.fromJson(data["data"]);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<bool> deleteHotspotLable(
      {required String apikey,
      required int imageId,
      required int hotspotId,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final response = await dio
          .get("image/$imageId/removeinfospot/$hotspotId?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == 'success') {
        if (onSuccess != null) onSuccess();
        return true;
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<VTHotspotLink> addHotspotLink(
      {required String apiKey,
      required int imageId,
      required int toImageId,
      required double x,
      required double y,
      required double z,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    final map = <String, dynamic>{};
    map['image_id'] = imageId;
    map['to_image'] = toImageId;
    map['positions_x'] = "$x";
    map['positions_y'] = "$y";
    map['positions_z'] = "$z";
    final body = FormData.fromMap(map);
    try {
      final response = await dio
          .post("image/$imageId/addlinkspot?apikey=$apiKey", data: body);
      final data = jsonDecode(response.toString());
      if (data['status'] == 'success') {
        if (onSuccess != null) onSuccess();
        data['data']['positions'] = {
          'x': data['data']['positions_x'],
          'y': data['data']['positions_y'],
          'z': data['data']['positions_z'],
        };
        return VTHotspotLink.fromJson(data['data']);
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  Future<bool> deleteHotspotLink(
      {required String apikey,
      required int imageId,
      required int hotspotId,
      OnSuccess? onSuccess,
      OnError? onError}) async {
    try {
      final response = await dio
          .get("image/$imageId/removelinkspot/$hotspotId?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == 'success') {
        if (onSuccess != null) onSuccess();
        return true;
      } else {
        if (onError != null) onError(response.statusCode!, data['message']);
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      if (onError != null) {
        onError(e.response != null ? e.response!.statusCode! : 0, e.message);
      }
      throw Exception(e.message);
    }
  }

  
}
