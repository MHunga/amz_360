import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amz_360/amz_360.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum HotspotType { text, image, video, link }

class ViewVR extends StatefulWidget {
  final int id;
  const ViewVR({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewVR> createState() => _ViewVRState();
}

class _ViewVRState extends State<ViewVR> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  StreamController<double?> progressController = StreamController.broadcast();
  StreamController<HotspotType> dialogController = StreamController.broadcast();
  StreamController<File?> selectImageHotspotController =
      StreamController.broadcast();
  StreamController<File?> selectVideoHotspotController =
      StreamController.broadcast();
  StreamController<int?> tOtherImageIdController = StreamController.broadcast();
  StreamController<bool> progressDialogController =
      StreamController.broadcast();
  bool reload = false;
  File? file;
  File? video;
  int? toImageId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _pickingImage();
          },
          child: const Icon(Icons.image)),
      body: Stack(
        children: [
          SafeArea(
            child: reload
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Amz360View.client(
                    id: widget.id,
                    textHotspotIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff558cd8), width: 5),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.info_outlined, size: 16),
                    ),
                    imageHotspotIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff558cd8), width: 5),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.image, size: 16),
                    ),
                    videoHotspotIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff558cd8), width: 5),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.ondemand_video_rounded, size: 16),
                    ),
                    toOtherImageHotspotIcon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff558cd8), width: 5),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child:
                          const Icon(Icons.arrow_circle_up_rounded, size: 16),
                    ),
                    autoRotationSpeed: 0.0,
                    enableSensorControl: false,
                    showControl: true,
                    onTap: (x, y, projectInfo) {
                      log("$x   $y");
                    },
                    onLongPressStart: (x, y, projectInfo) async {
                      log("$x   $y");
                      _showAddHotspotDialog(context, x, y, projectInfo);
                    },
                  ),
          ),
          StreamBuilder<double?>(
              initialData: null,
              stream: progressController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null && snapshot.data != 1) {
                    return Container(
                        color: Colors.black54,
                        child: Center(
                            child: CircularProgressIndicator(
                          value: snapshot.data,
                        )));
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              })
        ],
      ),
    );
  }

  _pickingImage() async {
    await _picker.pickMultiImage().then((value) async {
      if (value != null) {
        final List<File> list = [];
        for (var item in value) {
          list.add(File(item.path));
        }

        await Amz360.instance
            .uploadImageToProject(
          idProject: widget.id,
          images: list,
          progressCallback: (sentBytes, totalBytes) {
            progressController.add(sentBytes / totalBytes);
          },
        )
            .then((value) async {
          setState(() {
            reload = true;
          });
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {
            reload = false;
          });
        });
      }
    });
  }

  void _showAddHotspotDialog(
      BuildContext context, double x, double y, VTProject? projectInfo) {
    showDialog(
      context: context,
      builder: (_) => StreamBuilder<HotspotType>(
          initialData: HotspotType.text,
          stream: dialogController.stream,
          builder: (context, snapshot) {
            final type = snapshot.data!;
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                              onTap: type == HotspotType.text
                                  ? null
                                  : () {
                                      dialogController.add(HotspotType.text);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("TEXT",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: type == HotspotType.text
                                            ? Colors.blue
                                            : Colors.grey)),
                              )),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                              onTap: type == HotspotType.image
                                  ? null
                                  : () {
                                      dialogController.add(HotspotType.image);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("IMAGE",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: type == HotspotType.image
                                            ? Colors.blue
                                            : Colors.grey)),
                              )),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                              onTap: type == HotspotType.video
                                  ? null
                                  : () {
                                      dialogController.add(HotspotType.video);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("VIDEO",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: type == HotspotType.video
                                            ? Colors.blue
                                            : Colors.grey)),
                              )),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                              onTap: type == HotspotType.link
                                  ? null
                                  : () {
                                      dialogController.add(HotspotType.link);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("LINK",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: type == HotspotType.link
                                            ? Colors.blue
                                            : Colors.grey)),
                              )),
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<bool>(
                      initialData: false,
                      stream: progressDialogController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data!) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 8),
                            if (type != HotspotType.link)
                              TextFormField(
                                controller: titleController,
                                decoration:
                                    const InputDecoration(labelText: "Title"),
                              ),
                            const SizedBox(height: 8),
                            if (type == HotspotType.text)
                              TextFormField(
                                controller: textController,
                                decoration: const InputDecoration(
                                    labelText: "Description"),
                              ),
                            if (type == HotspotType.image)
                              StreamBuilder<File?>(
                                  initialData: null,
                                  stream: selectImageHotspotController.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
                                      return ElevatedButton.icon(
                                          onPressed: _pickingImageHotspot,
                                          icon: const Icon(Icons.upload),
                                          label: const Text("Select Image"));
                                    } else {
                                      return GestureDetector(
                                        onTap: _pickingImageHotspot,
                                        child: SizedBox(
                                          height: 150,
                                          child: Image.file(snapshot.data!),
                                        ),
                                      );
                                    }
                                  }),
                            if (type == HotspotType.video)
                              StreamBuilder<File?>(
                                  initialData: null,
                                  stream: selectVideoHotspotController.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
                                      return ElevatedButton.icon(
                                          onPressed: _pickingVideoHotspot,
                                          icon: const Icon(Icons.upload),
                                          label: const Text("Select Video"));
                                    } else {
                                      return GestureDetector(
                                        onTap: _pickingVideoHotspot,
                                        child: SizedBox(
                                          height: 150,
                                          child: Text(snapshot.data!.path
                                              .split("/")
                                              .last),
                                        ),
                                      );
                                    }
                                  }),
                            if (type == HotspotType.link)
                              StreamBuilder<int?>(
                                  initialData: null,
                                  stream: tOtherImageIdController.stream,
                                  builder: (context, snapshot) {
                                    return SizedBox(
                                      height: 150,
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: ListView.builder(
                                        itemCount: projectInfo!.images!.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          if (projectInfo
                                                  .images![index].image!.id ==
                                              projectInfo
                                                  .currentImage!.image!.id) {
                                            return const SizedBox.shrink();
                                          }
                                          return GestureDetector(
                                            onTap: () {
                                              toImageId = projectInfo
                                                  .images![index].image!.id;
                                              tOtherImageIdController
                                                  .add(toImageId);
                                            },
                                            child: Container(
                                              height: 150,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              margin: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  border: snapshot.data != null
                                                      ? snapshot.data ==
                                                              projectInfo
                                                                  .images![
                                                                      index]
                                                                  .image!
                                                                  .id
                                                          ? Border.all(
                                                              color:
                                                                  Colors.blue,
                                                              width: 3)
                                                          : null
                                                      : null,
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          projectInfo
                                                              .images![index]
                                                              .image!
                                                              .thumbnailUrl!))),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  })
                          ],
                        );
                      })
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      progressDialogController.add(true);
                      if (type == HotspotType.text) {
                        await Amz360.instance.addHotspotLable(
                            idImage: projectInfo!.currentImage!.image!.id!,
                            title: titleController.text,
                            text: textController.text,
                            x: x,
                            y: y);
                      }
                      if (type == HotspotType.image) {
                        if (file != null) {
                          await Amz360.instance.addHotspotLable(
                              idImage: projectInfo!.currentImage!.image!.id!,
                              title: titleController.text,
                              image: file,
                              x: x,
                              y: y);
                        }
                      }
                      if (type == HotspotType.video) {
                        if (video != null) {
                          await Amz360.instance.addHotspotLable(
                              idImage: projectInfo!.currentImage!.image!.id!,
                              title: titleController.text,
                              video: video,
                              progressCallback: (byte, total) {
                                log("$byte/$total");
                              },
                              x: x,
                              y: y);
                        }
                      }
                      if (type == HotspotType.link) {
                        if (toImageId != null) {
                          await Amz360.instance.addHotspotToOtherImage(
                              idImage: projectInfo!.currentImage!.image!.id!,
                              toImageId: toImageId!,
                              x: x,
                              y: y);
                        }
                      }
                      progressDialogController.add(false);
                      Navigator.pop(context);
                    },
                    child: const Text("OK"))
              ],
            );
          }),
    );
  }

  void _pickingImageHotspot() async {
    await _picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        file = File(value.path);
        selectImageHotspotController.add(file);
      }
    });
  }

  void _pickingVideoHotspot() async {
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    ).then((value) {
      if (value != null) {
        video = File(value.files.single.path!);
        selectVideoHotspotController.add(video);
      }
    });
  }
}
