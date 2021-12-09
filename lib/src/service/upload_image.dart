// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as file_util;

// typedef OnDone = void Function();

// class UploadImage {
//   late HttpClientRequest request;

//   HttpClient getHttpClient() {
//     HttpClient httpClient = HttpClient()
//       ..connectionTimeout = const Duration(seconds: 10)
//       ..badCertificateCallback =
//           ((X509Certificate cert, String host, int port) => true);

//     return httpClient;
//   }

//   Future<String> upLoadFile(
//       {required File file,
//       required String apiKey,
//       OnUploadProgressCallback? onUploadProgress,
//       OnDone? onDone}) async {
//     final url =
//         'https://api.modernbiztech.com/api/v1/app/project/uploadimage?apikey=$apiKey';

//     final httpClient = getHttpClient();

//     request = await httpClient.postUrl(Uri.parse(url));

//     int byteCount = 0;
//     var multipart = await http.MultipartFile.fromPath(
//       file_util.basename(file.path),
//       file.path,
//     );

//     var requestMultipart = http.MultipartRequest("POST", Uri.parse(url));

//     requestMultipart.files.add(multipart);

//     var msStream = requestMultipart.finalize();

//     var totalByteLength = requestMultipart.contentLength;

//     request.contentLength = totalByteLength;

//     request.headers.set(HttpHeaders.contentTypeHeader,
//         requestMultipart.headers[HttpHeaders.contentTypeHeader]!);

//     Stream<List<int>> streamUpload = msStream.transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           sink.add(data);
//           byteCount += data.length;

//           if (onUploadProgress != null) {
//             onUploadProgress(byteCount, totalByteLength);
//             // CALL STATUS CALLBACK;
//           }
//         },
//         handleError: (error, stack, sink) {
//           throw error;
//         },
//         handleDone: (sink) {
//           sink.close();
//           if (onDone != null) {
//             onDone();
//           }
//           // UPLOAD DONE;
//         },
//       ),
//     );

//     await request.addStream(streamUpload);

//     final httpResponse = await request.close();
// //
//     var statusCode = httpResponse.statusCode;

//     if (statusCode ~/ 100 != 2) {
//       throw Exception(
//           "Error uploading file, Status code: ${httpResponse.statusCode}");
//       //return "";
//     } else {
//       //log("success");
//       return await readResponseAsString(httpResponse);
//     }
//   }

//   Future<String> readResponseAsString(HttpClientResponse response) {
//     var completer = Completer<String>();
//     var contents = StringBuffer();
//     response.transform(utf8.decoder).listen((String data) {
//       contents.write(data);
//     }, onDone: () => completer.complete(contents.toString()));
//     return completer.future;
//   }
// }
