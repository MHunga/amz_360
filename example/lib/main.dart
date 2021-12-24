import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:amz_360/amz_360.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  Amz360.instance.setClient("1p7g4RrCOpQM2ze4rki1j4KvK");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> lisfile = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("360 example"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _picker.pickMultiImage().then((value) async {
            if (value != null) {
              for (var item in value) {
                lisfile.add(File(item.path));
              }
              await Amz360.instance
                  .create(
                title: "Titlexxxđasasssxx",
                descrition: "Descriptionssss",
                images: lisfile,
                progressCallback: (sentBytes, totalBytes) {
                  print("Progress: $sentBytes/$totalBytes");
                },
              )
                  .then((value) {
                setState(() {});
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
          child: FutureBuilder<ResponseVtListProject>(
        future: Amz360.instance.getListProject(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.hasData) {
            final list = snapshot.data!.data!;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ViewVR(id: list[index].id!)));
                        },
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            list[index].images!.url!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          list[index].title ?? "",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider()
                    ],
                  ),
                  Positioned(
                    bottom: 8,
                    right: 0,
                    child: ElevatedButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await Amz360.instance
                              .deleteProject(list[index].id!)
                              .then((value) {
                            setState(() {});
                          });
                        },
                        child: const Text("Xoá")),
                  )
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      )),
    );
  }
}

class ViewVR extends StatelessWidget {
  final int id;
  const ViewVR({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Amz360View.client(
          id: id,
          textHotspotIcon:
              ControlIcon(child: const Icon(Icons.info, color: Colors.white)),
          imageHotspotIcon:
              ControlIcon(child: const Icon(Icons.image, color: Colors.white)),
          videoHotspotIcon: ControlIcon(
              child: const Icon(Icons.ondemand_video_rounded,
                  color: Colors.white)),
          autoRotationSpeed: 0.0,
          enableSensorControl: true,
          showControl: true,
          onTap: (x, y, idImage) {
            log("$x   $y");
          },
          onLongPressStart: (x, y, idImage) async {
            log("$x   $y");
            await Amz360.instance.addHotspotLable(
                idImage: idImage!, title: "TESST", text: "Tessst", x: x, y: y);
          },
        ),
      ),
    );
  }
}
