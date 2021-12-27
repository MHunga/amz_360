
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:amz_360/amz_360.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool reload = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
   await _pickingImage();
        },
        child: const Icon(Icons.add_a_photo),),
      body: Stack(
        children: [
          SafeArea(
            child: reload ? const Center(child: CircularProgressIndicator.adaptive(),): Amz360View.client(
              id: widget.id,
              textHotspotIcon: const Icon(Icons.info, color: Colors.white),
              imageHotspotIcon: const Icon(Icons.image, color: Colors.white),
              videoHotspotIcon:
                  const Icon(Icons.ondemand_video_rounded, color: Colors.white),
              toOtherImageHotspotIcon:
                  const Icon(Icons.arrow_circle_up_rounded,  color: Colors.white),
              autoRotationSpeed: 0.0,
              enableSensorControl: false,
              showControl: false,
              onTap: (x, y, projectInfo) {
                log("$x   $y");
              },
              onLongPressStart: (x, y, projectInfo) async {
                log("$x   $y");
               
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Add text hotspot"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: titleController,
                                decoration:
                                    const InputDecoration(labelText: "Title"),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: textController,
                                decoration:
                                    const InputDecoration(labelText: "Description"),
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("OK"))
                          ],
                        )).then((value) async {
                  if (value != null) {
                    await Amz360.instance.addHotspotLable(
                        idImage: projectInfo!.currentImage!.image!.id!,
                        title: titleController.text,
                        text: textController.text,
                        x: x,
                        y: y);
                  }
                });
              },
            ),
          ),
          StreamBuilder<double?>(
              initialData: null,
              stream: progressController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
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
       
       await Amz360.instance.uploadImageToProject(idProject: widget.id, images: list,
       progressCallback: (sentBytes, totalBytes) {
         progressController.add(sentBytes/totalBytes);
       },
       ).then((value) async{
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
}