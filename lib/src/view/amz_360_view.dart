import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:amz_360/src/models/project_info.dart';
import 'package:amz_360/src/scene/mesh.dart';
import 'package:amz_360/src/scene/scene.dart';
import 'package:amz_360/src/scene/scene_view.dart';
import 'package:amz_360/src/sensor/sensor.dart';
import 'package:amz_360/src/utils/utils.dart';
import 'package:amz_360/src/vibrate/vibrate.dart';
import 'package:amz_360/src/view/edit_profile_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import 'package:amz_360/src/scene/object.dart';

import 'edit_hotspot_dialog.dart';
import '../models/hotspot.dart';
import 'menu_control.dart';

typedef EventCallback = Function(
    double longitude, double latitude, double tilt);

enum Amz360ViewType {
  /// 360° display mode.
  view360,

  /// Original picture display mode.
  viewOriginalImage,

  /// Only Image in scene display mode.
  viewOnlyImageInScene
}

class Amz360View extends StatefulWidget {
  final String? id;

  /// The initial zoom, default to 1.0.
  final double zoom;

  /// visualizer auto rotation speed. default to 0.0
  final double autoRotationSpeed;

  /// Display mode . Default to [Amz360ViewType.view360]
  final Amz360ViewType displayMode;

  /// Enable Sensor control. default to false.
  final bool enableSensorControl;

  /// The minimal zomm. default to 1.0
  final double minZoom;

  /// The maximal zomm. default to 5.0
  final double maxZoom;

  /// This event will be called when the user has tapped, it contains latitude and longitude about where the user tapped.
  final EventCallback? onTap;

  /// This event will be called when the user has started a long press, it contains latitude and longitude about where the user pressed.
  final EventCallback? onLongPressStart;

  /// This event will be called when the user has drag-moved after a long press, it contains latitude and longitude about where the user pressed.
  final EventCallback? onLongPressMoveUpdate;

  /// This event will be called when the user has stopped a long presses, it contains latitude and longitude about where the user pressed.
  final EventCallback? onLongPressEnd;

  /// This event will be called when the view direction has changed, it contains latitude and longitude about the current view.
  final EventCallback? onViewChanged;

  ///
  final List<ControlIcon>? controlIcons;

  ///
  final bool showControl;

  final String? imageUrl;

  const Amz360View(
      {Key? key,
      this.id,
      this.zoom = 1.0,
      this.minZoom = 1.0,
      this.maxZoom = 5.0,
      this.onViewChanged,
      this.onTap,
      this.onLongPressStart,
      this.onLongPressMoveUpdate,
      this.onLongPressEnd,
      this.autoRotationSpeed = 0,
      this.enableSensorControl = false,
      this.displayMode = Amz360ViewType.view360,
      this.controlIcons = const [],
      this.showControl = false,
      this.imageUrl})
      : super(key: key);

  @override
  _Amz360ViewState createState() => _Amz360ViewState();
}

class _Amz360ViewState extends State<Amz360View> with TickerProviderStateMixin {
  final double minLatitude = -90;

  final double maxLatitude = 90;

  final double minLongitude = -180;

  final double maxLongitude = 180;

  Scene? scene;
  Object? surface;
  late double latitude;
  late double longitude;
  double latitudeDelta = 0;
  double longitudeDelta = 0;
  double zoomDelta = 0;
  late Offset _lastFocalPoint;
  double? _lastZoom;
  final double _radius = 500;
  final double _dampingFactor = 0.05;
  final double _animateDirection = 1.0;
  late AnimationController _controller;

  late AnimationController _moveController;
  late Animation<double> _scaleAnimation;
  late Animation<double> moveYAnimation;
  double screenOrientation = 0.0;
  Vector3 orientation = Vector3(0, radians(90), 0);
  StreamSubscription? _orientationSubscription;
  StreamSubscription? _screenOrientSubscription;
  ImageStream? _imageStream;
  late StreamController _streamController;
  Stream? _stream;

  double radian = 0;

  ControlIcon? hotspotWidget;

  ProjectImage? projectImage;

  late int currentIdImage;

  ProjectInfo projectInfo = ProjectInfo(
      id: "",
      title: "My City",
      author: "Mr Hung",
      description: "this is my description of my city",
      initImageId: 0,
      location: "Ha Noi, Viet Nam",
      images: [
        ProjectImage(
            id: 0,
            image:
                "https://saffi3d.files.wordpress.com/2011/08/12-marla-copy.jpg",
            hotspots: []),
        ProjectImage(
            id: 1,
            image:
                "https://saffi3d.files.wordpress.com/2011/08/commercial_area_cam_v004.jpg",
            hotspots: []),
        ProjectImage(
            id: 2,
            image:
                "https://saffi3d.files.wordpress.com/2011/08/community-club-pano_v009.jpg",
            hotspots: []),
        ProjectImage(
            id: 3,
            image:
                "https://saffi3d.files.wordpress.com/2011/08/enterance_gate_v0014.jpg",
            hotspots: []),
      ]);

  @override
  void initState() {
    super.initState();
    projectImage = projectInfo.images!
        .firstWhere((element) => element.id == projectInfo.initImageId);
    currentIdImage = projectImage!.id!;
    latitude = degrees(0);
    longitude = degrees(0);
    _streamController = StreamController.broadcast();
    _stream = _streamController.stream;

    _updateSensorControl();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..addListener(_updateView);

    _moveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            // longitude = _moveXAnimation.value;
            //latitude = moveYAnimation.value;
            if (_moveController.isCompleted) {
              projectImage = projectInfo.images!
                  .firstWhere((element) => element.id == currentIdImage);
              String? imageUrl;
              if (widget.imageUrl != null) {
                imageUrl = widget.imageUrl;
              } else {
                imageUrl = projectImage!.image;
              }
              _loadTexture(Image.network(imageUrl!).image);
              _streamController.add(null);
              _moveController.reset();
            }
          });

    _scaleAnimation = Tween<double>(begin: 1, end: 2).animate(
        CurvedAnimation(parent: _moveController, curve: Curves.easeOutQuart));

    // if (widget.sensorControl != SensorControl.None || widget.animSpeed != 0)
    _controller.repeat();
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateTexture));
    _orientationSubscription?.cancel();
    _screenOrientSubscription?.cancel();
    _streamController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Amz360View oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (surface == null) return;
    String? imageUrl;
    if (widget.imageUrl != null) {
      imageUrl = widget.imageUrl;
    } else {
      imageUrl = projectImage!.image;
    }
    _loadTexture(Image.network(imageUrl!).image);
  }

  @override
  Widget build(BuildContext context) {
    // precacheImage(NetworkImage(projectInfo.images![0].image!), context);
    // precacheImage(NetworkImage(projectInfo.images![1].image!), context);
    // precacheImage(NetworkImage(projectInfo.images![2].image!), context);
    // precacheImage(NetworkImage(projectInfo.images![3].image!), context);
    if (widget.displayMode == Amz360ViewType.viewOriginalImage) {
      return Image.network(projectInfo.images!
          .firstWhere((element) => element.id == projectInfo.initImageId)
          .image!);
    }
    return ClipRect(
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onTapUp: _handleTapUp,
        onLongPressStart: _handleLongPressStart,
        onLongPressMoveUpdate: _handleLongPressMoveUpdate,
        onLongPressEnd: _handleLongPressEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _moveController,
              builder: (context, child) => Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4(
                    // @formatter:off
                    1,
                    0,
                    0,
                    0,
                    //column
                    0,
                    1,
                    0,
                    -0.0003 * _scaleAnimation.value,
                    //
                    0,
                    0,
                    1,
                    0,
                    //
                    0,
                    0,
                    0,
                    1),
                // @formatter:on
                //scale: _scaleAnimation,
                child: Stack(
                  children: [
                    FadeTransition(
                        opacity: Tween<double>(begin: 1, end: 0.5)
                            .animate(_moveController),
                        child: ScenceView(onSceneCreated: _onSceneCreated)),
                    StreamBuilder(
                        stream: _stream,
                        builder: (context, snapshot) {
                          return buildHotspotWidgets(projectImage!.hotspots!);
                        }),
                  ],
                ),
              ),
            ),

            if (widget.showControl)
              Positioned(
                top: 16,
                left: 16,
                child: MenuControl(
                  children: widget.controlIcons!,
                  callbackSelected: (widget) {
                    hotspotWidget = widget;

                    _streamController.add(null);
                  },
                ),
              ),
            // if (widget.showControl)
            //   Positioned(
            //       top: 16,
            //       right: 16,
            //       child: MenuAction(
            //           isSelected: false,
            //           onTap: () {},
            //           child: const Icon(Icons.zoom_out_map,
            //               color: Color(0xffffffff)))),
            if (widget.showControl)
              Positioned(
                  top: 14,
                  child: StreamBuilder(
                      stream: _stream,
                      builder: (context, snapshot) {
                        return ElevatedButton.icon(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => EditProfileProjectDialog(
                                  projectInfo: projectInfo,
                                ),
                              ).then((value) {
                                if (value != null) {
                                  projectInfo.changeInfo(
                                      title: value["title"],
                                      description: value["descriptions"],
                                      author: value["author"],
                                      location: value["location"]);
                                  _streamController.add(null);
                                }
                              });
                            },
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff000000).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xffffffff),
                            ),
                            label: Text(projectInfo.title ?? ""));
                      })),
            if (widget.showControl)
              Positioned(
                  left: 16,
                  bottom: 16,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xff000000).withOpacity(0.5),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        StreamBuilder(
                            stream: _stream,
                            builder: (context, snapshot) {
                              return Transform.rotate(
                                angle: radian,
                                child: CustomPaint(
                                  painter: ControlChervonPainter(),
                                ),
                              );
                            }),
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: Color(0xffffffff),
                        )
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget buildHotspotWidgets(List<Hotspot>? hotspots) {
    final List<Widget> widgets = <Widget>[];
    if (hotspots != null && scene != null) {
      for (Hotspot hotspot in hotspots) {
        final Vector3 pos = Amz360Utils.shared
            .positionFromLatLon(scene!, hotspot.latitude, hotspot.longitude);
        final Offset orgin =
            Offset(60 * hotspot.orgin.dx, 60 * hotspot.orgin.dy);
        final Matrix4 transform = scene!.camera.lookAtMatrix *
            Amz360Utils.shared
                .matrixFromLatLon(hotspot.latitude, hotspot.longitude);
        final Widget child = Positioned(
          left: pos.x - orgin.dx,
          top: pos.y - orgin.dy,
          child: Transform(
            origin: orgin,
            transform: transform..invert(),
            child: Offstage(
              offstage: pos.z < 0,
              child: hotspot.widget,
            ),
          ),
        );
        widgets.add(child);
      }
    }
    return Stack(children: widgets);
  }

  void _handleTapUp(TapUpDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onTap != null) {
      widget.onTap!(degrees(o.x), degrees(-o.y), degrees(o.z));
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) async {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (hotspotWidget != null) {
      _controller.stop();
      Vibrate.vibrate();
      projectImage!.hotspots!.add(Hotspot(
          latitude: degrees(-o.y),
          longitude: degrees(o.x),
          title: "Title",
          description: "This is Descriptions",
          callbackMovement: (idImage, lat, long) {
            currentIdImage = idImage;
            _moveController.forward();
          },
          icon: hotspotWidget!));

      if (hotspotWidget!.iconType == IconType.info) {
        await showDialog(
          context: context,
          builder: (context) => EditInfoHotspotDialog(),
        ).then((value) {
          _controller.repeat();
          if (value != null) {
            projectImage!.hotspots!.last
                .changeInfo(value["title"], value["descriptions"]);
            _streamController.add(null);
          } else {
            projectImage!.hotspots!.removeLast();
            _streamController.add(null);
          }
        });
      } else {
        await showDialog(
          context: context,
          builder: (context) => EditMovementHotspotDialog(
            images: projectInfo.images!,
          ),
        ).then((value) {
          _controller.repeat();
          if (value != null) {
            projectImage!.hotspots!.last.addImage(value);
            _streamController.add(null);
          } else {
            projectImage!.hotspots!.removeLast();
            _streamController.add(null);
          }
        });
      }
      // showGeneralDialog(
      //   context: context,
      //   useRootNavigator: false,

      //   pageBuilder: (context, animation, secondaryAnimation) =>
      //       const EditHotspotDialog(),
      // );
    }

    if (widget.onLongPressStart != null) {
      widget.onLongPressStart!(degrees(o.x), degrees(-o.y), degrees(o.z));
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    //log("${o.x} .. ${o.y} .. ${o.z}");
    if (widget.onLongPressMoveUpdate != null) {
      widget.onLongPressMoveUpdate!(degrees(o.x), degrees(-o.y), degrees(o.z));
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onLongPressEnd != null) {
      widget.onLongPressEnd!(degrees(o.x), degrees(-o.y), degrees(o.z));
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _lastZoom = null;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final offset = details.localFocalPoint - _lastFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    latitudeDelta +=
        1 * 0.5 * math.pi * offset.dy / scene!.camera.viewportHeight;
    longitudeDelta -= 1 *
        _animateDirection *
        0.5 *
        math.pi *
        offset.dx /
        scene!.camera.viewportHeight;
    _lastZoom ??= scene!.camera.zoom;
    zoomDelta += _lastZoom! * details.scale - (scene!.camera.zoom + zoomDelta);
    // if (widget.sensorControl == SensorControl.None &&
    //     !_controller.isAnimating) {
    //   _controller.reset();
    //   if (widget.animSpeed != 0) {
    //     _controller.repeat();
    //   } else
    //     _controller.forward();
    // }
  }

  void _updateSensorControl() {
    _orientationSubscription?.cancel();
    amzSensors.orientationUpdateInterval = Duration.microsecondsPerSecond ~/ 60;
    _orientationSubscription = amzSensors.orientation.listen((event) {
      if (widget.enableSensorControl &&
          widget.displayMode == Amz360ViewType.view360) {
        orientation.setValues(event.yaw, event.pitch, event.roll);
      }
    });

    _screenOrientSubscription?.cancel();
  }

  void _onSceneCreated(Scene scene) {
    this.scene = scene;
    scene.camera.near = 1.0;
    scene.camera.far = _radius + 1.0;
    scene.camera.fov = 75;
    scene.camera.zoom = widget.zoom;
    scene.camera.position.setFrom(Vector3(0, 0, 0.1));
    if (projectImage != null) {
      final Mesh mesh = Amz360Utils.shared.generateSphereMesh(
          croppedArea: const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
          croppedFullWidth: 1.0,
          croppedFullHeight: 1.0);
      surface = Object(name: 'surface', mesh: mesh, backfaceCulling: false);
      String? imageUrl;
      if (widget.imageUrl != null) {
        imageUrl = widget.imageUrl;
      } else {
        imageUrl = projectImage!.image;
      }
      _loadTexture(Image.network(imageUrl!).image);
      scene.world.add(surface!);
      _updateView();
    }
  }

  void _loadTexture(ImageProvider? provider) {
    if (provider == null) return;
    _imageStream?.removeListener(ImageStreamListener(_updateTexture));
    _imageStream = provider.resolve(const ImageConfiguration());
    ImageStreamListener listener = ImageStreamListener(_updateTexture);
    _imageStream!.addListener(listener);
  }

  void _updateTexture(ImageInfo imageInfo, bool synchronousCall) {
    surface?.mesh.texture = imageInfo.image;
    surface?.mesh.textureRect = Rect.fromLTWH(0, 0,
        imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
    scene!.texture = imageInfo.image;
    scene!.update();
  }

  void _updateView() {
    if (scene == null) return;
    // auto rotate
    if (widget.autoRotationSpeed > 0) {
      longitudeDelta += 0.001 * widget.autoRotationSpeed;
    }
    // animate vertical rotating
    latitude += latitudeDelta * _dampingFactor;
    latitudeDelta *= 1 - _dampingFactor;
    // animate horizontal rotating
    longitude += _animateDirection * longitudeDelta * _dampingFactor;
    longitudeDelta *= 1 - _dampingFactor;
    // animate zomming
    final double zoom = scene!.camera.zoom + zoomDelta * _dampingFactor;
    zoomDelta *= 1 - _dampingFactor;
    scene!.camera.zoom = zoom.clamp(widget.minZoom, widget.maxZoom);
    // stop animation if not needed
    // if (latitudeDelta.abs() < 0.001 &&
    //     longitudeDelta.abs() < 0.001 &&
    //     zoomDelta.abs() < 0.001) {
    //   // if (widget.animSpeed == 0 && _controller.isAnimating) _controller.stop();
    // }

    // rotate for screen orientation
    Quaternion q = Quaternion.axisAngle(Vector3(0, 0, 1), screenOrientation);
    // rotate for device orientation
    q *= Quaternion.euler(-orientation.z, -orientation.y, -orientation.x);
    // rotate to latitude zero
    q *= Quaternion.axisAngle(Vector3(1, 0, 0), math.pi * 0.5);

    // check and limit the rotation range
    Vector3 o = Amz360Utils.shared.quaternionToOrientation(q);
    final double minLat = radians(math.max(-89.9, minLatitude));
    final double maxLat = radians(math.min(89.9, maxLatitude));
    final double minLon = radians(minLongitude);
    final double maxLon = radians(maxLongitude);
    final double lat = (-o.y).clamp(minLat, maxLat);
    final double lon = o.x.clamp(minLon, maxLon);
    if (lat + latitude < minLat) latitude = minLat - lat;
    if (lat + latitude > maxLat) latitude = maxLat - lat;
    if (maxLon - minLon < math.pi * 2) {
      if (lon + longitude < minLon || lon + longitude > maxLon) {
        longitude = (lon + longitude < minLon ? minLon : maxLon) - lon;
        // reverse rotation when reaching the boundary
        // if (widget.animSpeed != 0) {
        //   if (widget.animReverse)
        //     _animateDirection *= -1.0;
        //   else
        //     _controller.stop();
        // }
      }
    }
    o.x = lon;
    o.y = -lat;
    q = Amz360Utils.shared.orientationToQuaternion(o);

    // rotate to longitude zero
    q *= Quaternion.axisAngle(Vector3(0, 1, 0), -math.pi * 0.5);
    // rotate around the global Y axis
    q *= Quaternion.axisAngle(Vector3(0, 1, 0), longitude);
    // rotate around the local X axis
    q = Quaternion.axisAngle(Vector3(1, 0, 0), -latitude) * q;

    o = Amz360Utils.shared.quaternionToOrientation(
        q * Quaternion.axisAngle(Vector3(0, 1, 0), math.pi * 0.5));
    widget.onViewChanged?.call(degrees(o.x), degrees(-o.y), degrees(o.z));
    radian = o.x;
    q.rotate(scene!.camera.target..setFrom(Vector3(0, 0, -500)));
    q.rotate(scene!.camera.up..setFrom(Vector3(0, 1, 0)));
    scene!.update();
    _streamController.add(null);
    if (widget.displayMode != Amz360ViewType.view360) {
      _controller.stop();
    }
  }
}

class ControlChervonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xffffffff).withOpacity(0.5);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: 50),
        -pi / 2 - pi / 8, pi / 4, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
