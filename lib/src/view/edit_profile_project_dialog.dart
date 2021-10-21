import 'dart:ui';

import 'package:amz_360/src/models/project_info.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditProfileProjectDialog extends StatelessWidget {
  EditProfileProjectDialog({
    Key? key,
    required this.projectInfo,
  }) : super(key: key) {
    titleController = TextEditingController(text: projectInfo.title);
    descriptionsController =
        TextEditingController(text: projectInfo.description);
    authorController = TextEditingController(text: projectInfo.author);
    locationController = TextEditingController(text: projectInfo.location);
    formKey = GlobalKey<FormState>();
  }
  final ProjectInfo projectInfo;
  late TextEditingController titleController;
  late TextEditingController descriptionsController;
  late TextEditingController authorController;
  late TextEditingController locationController;
  late GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Title",
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Can not empty";
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionsController,
                  maxLines: 6,
                  decoration: InputDecoration(
                      filled: true,
                      labelText: "Descriptions",
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Can not empty";
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: authorController,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Author",
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Can not empty";
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Location",
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Can not empty";
                    }
                  },
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
                              "descriptions": descriptionsController.text,
                              "author": authorController.text,
                              "location": locationController.text
                            });
                          }
                        },
                        child: const Text("OK"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
