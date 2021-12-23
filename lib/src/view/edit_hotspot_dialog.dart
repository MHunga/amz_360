import 'dart:async';

import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditInfoHotspotDialog extends StatelessWidget {
  EditInfoHotspotDialog({
    Key? key,
  }) : super(key: key);
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionsController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamController<bool> typeController = StreamController.broadcast();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Form(
        key: formKey,
        child: StreamBuilder<bool>(
            initialData: false,
            stream: typeController.stream,
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                typeController.add(false);
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: snapshot.data!
                                      ? Colors.white
                                      : Colors.black,
                                  minimumSize: const Size(double.infinity, 50)),
                              child: Text("TEXT",
                                  style: TextStyle(
                                      color: snapshot.data!
                                          ? Colors.black
                                          : Colors.white))),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                typeController.add(true);
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: !snapshot.data!
                                      ? Colors.white
                                      : Colors.black,
                                  minimumSize: const Size(double.infinity, 50)),
                              child: Text("IMAGE",
                                  style: TextStyle(
                                      color: !snapshot.data!
                                          ? Colors.black
                                          : Colors.white))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      controller: titleController,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Title",
                        filled: true,
                        fillColor: Colors.black12,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "Can not empty";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!snapshot.data!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextFormField(
                        controller: descriptionsController,
                        maxLines: 6,
                        decoration: InputDecoration(
                            filled: true,
                            hintText: "Descriptions",
                            fillColor: Colors.black12,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8))),
                        validator: (v) {
                          if (v!.isEmpty) {
                            return "Can not empty";
                          }
                        },
                      ),
                    ),
                  if (snapshot.data!)
                    Container(
                      height: 153,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Select Image"),
                          SizedBox(width: 8),
                          Icon(Icons.upload_sharp)
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          )),
                      TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context, {
                                "title": titleController.text,
                                "descriptions": descriptionsController.text
                              });
                            }
                          },
                          child: const Text("OK"))
                    ],
                  )
                ],
              );
            }),
      ),
    );
  }
}

class EditMovementHotspotDialog extends StatelessWidget {
  const EditMovementHotspotDialog({Key? key, required this.images})
      : super(key: key);
  final List<VTImage> images;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context, images[index].image!.id);
                    },
                    child: Image.network(images[index].image!.url!)),
              ),
            )),
      ),
    );
  }
}
