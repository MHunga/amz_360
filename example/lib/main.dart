import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:amz_360/amz_360.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Amz360View(
            //id: "",
            displayMode: Amz360ViewType.viewOnlyImageInScene,
            imageUrl:
                "https://saffi3d.files.wordpress.com/2011/08/12-marla-copy.jpg",
            autoRotationSpeed: 0.0,
            enableSensorControl: true,
            // showControl: true,
            controlIcons: [
              ControlIcon(
                  child: Image.asset("assets/info.png", width: 24, height: 24)),
              ControlIcon(
                  child: const Icon(Icons.location_on, color: Colors.white)),
              ControlIcon(
                  iconType: IconType.movement,
                  child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Image.asset("assets/chervon.png",
                          width: 24, height: 24)))
            ],
            onTap: (long, lat, t) {
              log("$long   $lat, $t");
            },
            onLongPressStart: (long, lat, t) {
              log("$long   $lat, $t");
            },
          ),
        ),
      ),
    );
  }
}
