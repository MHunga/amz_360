import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:amz_360/amz_360.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'vr_view_screen.dart';

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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  StreamController<double?> progressController = StreamController.broadcast();
  StreamController<List<File>> selectImageController =
      StreamController.broadcast();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("360 example"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showCreateDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          SafeArea(
              child: FutureBuilder<ResponseVtListProject>(
            future: Amz360.instance.getListProject(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
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
                                      builder: (_) =>
                                          ViewVR(id: list[index].id!)));
                            },
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                list[index].images!.thumbnailUrl!,
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
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              await Amz360.instance
                                  .deleteProject(id: list[index].id!)
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

  void _showCreateDialog(BuildContext context) {
    showDialog<List<File>?>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("New Project"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Can not empty";
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Descriptions"),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Can not empty";
                          }
                        }),
                    const SizedBox(height: 8),
                    StreamBuilder<List<File>>(
                        initialData: const [],
                        stream: selectImageController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.data!.isEmpty) {
                            return ElevatedButton.icon(
                                onPressed: () async {
                                  await _pickingImage();
                                },
                                icon: const Icon(Icons.upload),
                                label: const Text("Select Image"));
                          } else {
                            return SizedBox(
                              height: 150,
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child:
                                            Image.file(snapshot.data![index]),
                                      )),
                            );
                          }
                        })
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                StreamBuilder<List<File>>(
                    initialData: const [],
                    stream: selectImageController.stream,
                    builder: (context, snapshot) {
                      return TextButton(
                          onPressed: snapshot.data!.isNotEmpty
                              ? () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(context, snapshot.data!);
                                  }
                                }
                              : null,
                          child: const Text("OK"));
                    })
              ],
            )).then((value) async {
      if (value != null) {
        await Amz360.instance
            .create(
              title: titleController.text,
              descrition: descriptionController.text,
              images: value,
              progressCallback: (sentBytes, totalBytes) {
                double progress = sentBytes / totalBytes;
                progressController.add(progress);
                if (progress == 1) {
                  progressController.add(null);
                }
              },
            )
            .then((value) => setState(() {
                  titleController.clear();
                  descriptionController.clear();
                  selectImageController.add([]);
                }));
      } else {
        titleController.clear();
        descriptionController.clear();
        selectImageController.add([]);
      }
    });
  }

  _pickingImage() async {
    await _picker.pickMultiImage().then((value) async {
      if (value != null) {
        final List<File> list = [];
        for (var item in value) {
          list.add(File(item.path));
        }
        selectImageController.add(list);
      }
    });
  }
}
