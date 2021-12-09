import 'dart:convert';
import 'dart:io';

import 'package:amz_360/src/models/response_vt_list_project.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:dio/dio.dart';

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);

class ApiService {
  final dio =
      Dio(BaseOptions(baseUrl: "https://api.modernbiztech.com/api/v1/app/"));

  Future<ResponseVtProject> create(
      {required String apiKey,
      required String title,
      required String describe,
      required List<File> images,
      OnUploadProgressCallback? progressCallback}) async {
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
        return ResponseVtProject.fromJson(data);
      } else {
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<ResponseVtListProject> getListProject({required String apiKey}) async {
    try {
      final response = await dio.get("project/index?apikey=$apiKey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        return ResponseVtListProject.fromJson(data);
      } else {
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> getProject(
      {required String apikey, required int id}) async {
    try {
      final response = await dio.get("project/$id?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        return ResponseVtProject.fromJson(data);
      } else {
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<ResponseVtProject> delete(
      {required String apikey, required int id}) async {
    try {
      final response = await dio.get("project/delete/$id?apikey=$apikey");
      final data = jsonDecode(response.toString());
      if (data['status'] == "success") {
        return ResponseVtProject.fromJson(data);
      } else {
        throw Exception(data['message']);
      }
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }
}

//  return ResponseVtProject(
//         status: "success",
//         message: "success",
//         data: VTProject(
//             author: "Hung",
//             id: 0,
//             description: "Description",
//             title: "Title",
//             images: [
//               VTImage(
//                   image: VTImageDetails(
//                       id: 0,
//                       thumbnailUrl: "",
//                       url:
//                           "https://saffi3d.files.wordpress.com/2011/08/12-marla-copy.jpg"),
//                   label: [
//                     VTHotspotLable(
//                         id: 0,
//                         imageId: 0,
//                         title: "First lable",
//                         text: "this is content lable")
//                   ]),
//               VTImage(
//                   image: VTImageDetails(
//                       id: 1,
//                       thumbnailUrl: "",
//                       url:
//                           "https://saffi3d.files.wordpress.com/2011/08/commercial_area_cam_v004.jpg"),
//                   label: [
//                     VTHotspotLable(
//                         id: 0,
//                         imageId: 0,
//                         title: "First lable",
//                         text: "this is content lable")
//                   ]),
//               VTImage(
//                   image: VTImageDetails(
//                       id: 2,
//                       thumbnailUrl: "",
//                       url:
//                           "https://saffi3d.files.wordpress.com/2011/08/community-club-pano_v009.jpg"),
//                   label: [
//                     VTHotspotLable(
//                         id: 0,
//                         imageId: 0,
//                         title: "First lable",
//                         text: "this is content lable")
//                   ])
//             ]));