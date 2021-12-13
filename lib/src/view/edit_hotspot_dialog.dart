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
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              const SizedBox(height: 8),
              TextFormField(
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
          ),
        ),
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
