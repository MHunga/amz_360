import 'dart:async';
import 'dart:ui';

import 'package:amz_360/amz_360.dart';
import 'package:amz_360/src/models/client_texture.dart';
import 'package:amz_360/src/models/response_vt_project.dart';
import 'package:amz_360/src/models/vt_hotspot.dart';
import 'package:amz_360/src/scene/mesh.dart';
import 'package:amz_360/src/scene/scene.dart';
import 'package:amz_360/src/scene/scene_view.dart';
import 'package:amz_360/src/sensor/sensor.dart';
import 'package:amz_360/src/utils/utils.dart';
import 'package:amz_360/src/vibrate/vibrate.dart';
import 'package:amz_360/src/view/hotspot_widget.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import 'package:amz_360/src/scene/object.dart';

import 'control_chervon_painter.dart';

typedef EventCallback = Function(double x, double y, VTProject? infoProject);

enum Amz360ViewType {
  /// 360° display mode.
  view360,

  /// Original picture display mode.
  viewOriginalImage,

  /// Only Image in scene display mode.
  viewOnlyImageInScene
}

class Amz360View extends _Amz360Scence {
  const Amz360View.client(
      {Key? key,
      required int id,
      Widget? textHotspotIcon,
      Widget? imageHotspotIcon,
      Widget? videoHotspotIcon,
      Widget? toOtherImageHotspotIcon,
      Widget? placeholderLoadingProject,
      Widget? placeholderLoadingImage,
      double autoRotationSpeed = 0,
      Amz360ViewType displayMode = Amz360ViewType.view360,
      bool enableSensorControl = false,
      double minZoom = 1.0,
      double maxZoom = 5.0,
      double zoom = 1.0,
      EventCallback? onLongPressEnd,
      EventCallback? onLongPressMoveUpdate,
      EventCallback? onLongPressStart,
      EventCallback? onTap,
      EventCallback? onViewChanged,
      bool showControl = false})
      :
        //assert(showControl != true || controlIcons != null),
        super(
            key: key,
            fromClient: true,
            idProject: id,
            autoRotationSpeed: autoRotationSpeed,
            textIcon: textHotspotIcon,
            imageIcon: imageHotspotIcon,
            videoIcon: videoHotspotIcon,
            toImageIcon: toOtherImageHotspotIcon,
            placeholderLoadingImage: placeholderLoadingImage,
            placeholderLoadingProject: placeholderLoadingProject,
            displayMode: displayMode,
            enableSensorControl: enableSensorControl,
            minZoom: minZoom,
            maxZoom: maxZoom,
            zoom: zoom,
            onLongPressEnd: onLongPressEnd,
            onLongPressMoveUpdate: onLongPressMoveUpdate,
            onLongPressStart: onLongPressStart,
            onTap: onTap,
            onViewChanged: onViewChanged,
            showControl: showControl);

  const Amz360View.url({
    Key? key,
    required String imageUrl,
    double autoRotationSpeed = 0,
    Amz360ViewType displayMode = Amz360ViewType.view360,
    bool enableSensorControl = false,
    double minZoom = 1.0,
    double maxZoom = 5.0,
    EventCallback? onLongPressEnd,
    EventCallback? onLongPressMoveUpdate,
    EventCallback? onLongPressStart,
    EventCallback? onTap,
    EventCallback? onViewChanged,
  }) : super(
            key: key,
            fromClient: false,
            imageUrl: imageUrl,
            autoRotationSpeed: autoRotationSpeed,
            displayMode: displayMode,
            enableSensorControl: enableSensorControl,
            minZoom: minZoom,
            maxZoom: maxZoom,
            onLongPressEnd: onLongPressEnd,
            onLongPressMoveUpdate: onLongPressMoveUpdate,
            onLongPressStart: onLongPressStart,
            onTap: onTap,
            onViewChanged: onViewChanged,
            showControl: false);

  const Amz360View.asset({
    Key? key,
    required String imageAsset,
    double autoRotationSpeed = 0,
    Amz360ViewType displayMode = Amz360ViewType.view360,
    bool enableSensorControl = false,
    double minZoom = 1.0,
    double maxZoom = 5.0,
    EventCallback? onLongPressEnd,
    EventCallback? onLongPressMoveUpdate,
    EventCallback? onLongPressStart,
    EventCallback? onTap,
    EventCallback? onViewChanged,
  }) : super(
            key: key,
            fromClient: false,
            imageAsset: imageAsset,
            autoRotationSpeed: autoRotationSpeed,
            displayMode: displayMode,
            enableSensorControl: enableSensorControl,
            minZoom: minZoom,
            maxZoom: maxZoom,
            onLongPressEnd: onLongPressEnd,
            onLongPressMoveUpdate: onLongPressMoveUpdate,
            onLongPressStart: onLongPressStart,
            onTap: onTap,
            onViewChanged: onViewChanged,
            showControl: false);
}

class _Amz360Scence extends StatefulWidget {
  final bool fromClient;

  final int? idProject;

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
  ///final List<ControlIcon>? controlIcons;
  final Widget? textIcon;

  ///
  final Widget? imageIcon;

  final Widget? videoIcon;

  final Widget? toImageIcon;

  final Widget? placeholderLoadingProject;

  final Widget? placeholderLoadingImage;

  final bool showControl;

  final String? imageUrl;

  final String? imageAsset;

  const _Amz360Scence(
      {Key? key,
      required this.fromClient,
      this.idProject,
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
      this.showControl = false,
      this.imageUrl,
      this.imageAsset,
      this.textIcon,
      this.imageIcon,
      this.videoIcon,
      this.toImageIcon,
      this.placeholderLoadingProject,
      this.placeholderLoadingImage})
      : super(key: key);

  @override
  _Amz360ScenceState createState() => _Amz360ScenceState();
}

class _Amz360ScenceState extends State<_Amz360Scence>
    with TickerProviderStateMixin {
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
  final double _radius = 5000;
  final double _dampingFactor = 0.05;
  final double _animateDirection = 1.0;
  late AnimationController _controller;
  late Animation<double> moveYAnimation;
  double screenOrientation = 0.0;
  Vector3 orientation = Vector3(0, radians(90), 0);
  StreamSubscription? _orientationSubscription;
  StreamSubscription? _screenOrientSubscription;

  late StreamController _streamController;
  Stream? _stream;

  double radian = 0;

  //ControlIcon? hotspotWidget;

  VTProject? vtProject;

  StreamSubscription<VTHotspotLable>? _addHotspotLableSubCription;
  StreamSubscription<VTHotspotLink>? _addHotspotLinkSubCription;

  List<ClientTexture> clientTextures = [];

  StreamController<double?> loadImageStreamController =
      StreamController.broadcast();

  bool showHotspot = false;

  late AnimationController fadeAnimationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));

  late Animation<double> fadeAnimation =
      Tween<double>(begin: 0, end: 1).animate(fadeAnimationController);

  @override
  void initState() {
    super.initState();
    initProject();
  }

  initProject() async {
    if (widget.fromClient) {
      await _getProject(widget.idProject);
    }

    latitude = degrees(0);
    longitude = degrees(0);
    _streamController = StreamController.broadcast();
    _stream = _streamController.stream;

    _updateSensorControl();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 40000), vsync: this)
      ..addListener(_updateView);

    _addHotspotLableSubCription =
        Amz360.instance.hotspotLableStreamController.stream.listen((hotspot) {
      if (vtProject != null) {
        if (vtProject!.currentImage != null) {
          vtProject!.currentImage!.addLable(hotspot);
          _streamController.add(null);
        }
      }
    });

    _addHotspotLinkSubCription =
        Amz360.instance.hotspotLinkStreamController.stream.listen((hotspot) {
      if (vtProject != null) {
        if (vtProject!.currentImage != null) {
          vtProject!.currentImage!.addLink(hotspot);
          _streamController.add(null);
        }
      }
    });
    _controller.repeat();
  }

  _getProject(int? idProject) async {
    setState(() {
      vtProject = null;
    });
    await Amz360.instance.getProject(id: widget.idProject!).then((value) {
      if (value.status == "success") {
        setState(() {
          vtProject = value.data;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var item in clientTextures) {
      item.dispose();
    }
    _orientationSubscription?.cancel();
    _screenOrientSubscription?.cancel();
    _addHotspotLableSubCription?.cancel();
    _addHotspotLinkSubCription?.cancel();
    _streamController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fromClient && vtProject == null) {
      return widget.placeholderLoadingProject ??
          const Material(
              child: Center(child: CircularProgressIndicator.adaptive()));
    }

    if (widget.displayMode == Amz360ViewType.viewOriginalImage) {
      if (!widget.fromClient) {
        if (widget.imageUrl != null) {
          return Image.network(widget.imageUrl!);
        } else if (widget.imageAsset != null) {
          return Image.asset(widget.imageAsset!);
        }
      } else {
        return Image.network(vtProject!.currentImage!.image!.url!);
      }
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
          children: [
            Stack(
              children: [
                ScenceView(onSceneCreated: _onSceneCreated),
                if (widget.fromClient)
                  StreamBuilder(
                      stream: _stream,
                      builder: (context, snapshot) {
                        if (showHotspot) {
                          return buildHotspotWidgets();
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                AnimatedBuilder(
                  animation: fadeAnimationController,
                  builder: (context, child) {
                    if (fadeAnimation.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: const Color(0xff000000)
                          .withOpacity(fadeAnimation.value),
                    );
                  },
                )
              ],
            ),
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
                  )),
            StreamBuilder<double?>(
              stream: loadImageStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return widget.placeholderLoadingImage ??
                      Material(
                        child: LinearProgressIndicator(
                          value: snapshot.data,
                        ),
                      );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildHotspotWidgets() {
    if (scene != null) {
      return Stack(
          children: List.generate(
              vtProject!.currentImage!.label!.length +
                  vtProject!.currentImage!.link!.length, (index) {
        dynamic hotspot;
        if (index < vtProject!.currentImage!.label!.length) {
          hotspot = vtProject!.currentImage!.label![index];
          if (hotspot.text != null) {
            hotspot.icon = widget.textIcon;
          }
          if (hotspot.imageUrl != null) {
            hotspot.icon = widget.imageIcon;
          }
          if (hotspot.videoUrl != null) {
            hotspot.icon = widget.videoIcon;
          }
        } else {
          hotspot = vtProject!.currentImage!
              .link![index - vtProject!.currentImage!.label!.length];
          hotspot.icon = widget.toImageIcon;
        }
        return HotspotWidget(
            scene: scene!,
            hotspot: hotspot,
            showControl: widget.showControl,
            callbackRemove: () async {
              if (hotspot is VTHotspotLable) {
                vtProject!.currentImage!.label!
                    .removeWhere((element) => element.id == hotspot.id);
              } else if (hotspot is VTHotspotLink) {
                vtProject!.currentImage!.link!
                    .removeWhere((element) => element.id == hotspot.id);
              }
            },
            callbackMovement: () async {
              if (hotspot is VTHotspotLink) {
                int index = 0;
                for (var i = 0; i < clientTextures.length; i++) {
                  if (hotspot.toImage.toString() ==
                      clientTextures[i].idImage.toString()) {
                    index = i;
                    break;
                  }
                }
                if (clientTextures[index].imageInfo != null) {
                  await _toOtherImage(index);
                } else {
                  clientTextures[index].progressCallback = (progress) async {
                    loadImageStreamController.add(progress);
                    if (progress == null) {
                      await _toOtherImage(index);
                    }
                  };
                }
              }
            },
            imageId: vtProject!.currentImage!.image!.id!);
      }));
    }

    return const SizedBox.shrink();
  }

  _toOtherImage(int index) async {
    fadeAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _updateTexture(clientTextures[index].imageInfo!, false);
    vtProject!.currentImage = vtProject!.images!.firstWhere((element) =>
        element.image!.id.toString() ==
        clientTextures[index].idImage.toString());
    _streamController.add(null);
    fadeAnimationController.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onTap != null) {
      widget.onTap!(degrees(o.x), degrees(-o.y), vtProject);
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) async {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onLongPressStart != null) {
      Vibrate.vibrate();
      widget.onLongPressStart!(degrees(o.x), degrees(-o.y), vtProject);
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onLongPressMoveUpdate != null) {
      widget.onLongPressMoveUpdate!(degrees(o.x), degrees(-o.y), vtProject);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final Vector3 o = Amz360Utils.shared.positionToLatLon(
        scene!, details.localPosition.dx, details.localPosition.dy);
    if (widget.onLongPressEnd != null) {
      widget.onLongPressEnd!(degrees(o.x), degrees(-o.y), vtProject);
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
    scene.camera.far = _radius + 10.0;
    scene.camera.fov = 60;
    scene.camera.zoom = widget.zoom;
    scene.camera.position.setFrom(Vector3(0, 0, 0.1));
    if (widget.fromClient && vtProject != null) {
      final Mesh mesh = Amz360Utils.shared.generateSphereMesh(
          croppedArea: const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
          croppedFullWidth: 1.0,
          croppedFullHeight: 1.0);
      surface = Object(name: 'surface', mesh: mesh, backfaceCulling: false);
      _loadClientTexture(vtProject!.images);
      scene.world.add(surface!);
      _updateView();
    } else {
      final Mesh mesh = Amz360Utils.shared.generateSphereMesh(
          croppedArea: const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
          croppedFullWidth: 1.0,
          croppedFullHeight: 1.0);
      surface = Object(name: 'surface', mesh: mesh, backfaceCulling: false);
      if (widget.imageUrl != null) {
        _loadTexture(true, widget.imageUrl);
      } else if (widget.imageAsset != null) {
        _loadTexture(false, widget.imageAsset);
      }
      scene.world.add(surface!);
      _updateView();
    }
  }

  void _loadClientTexture(List<VTImage>? images) {
    if (images == null) return;
    for (var i = 0; i < images.length; i++) {
      clientTextures.add(ClientTexture(
        isNetwork: true,
        idImage: images[i].image!.id,
        imageUrl: images[i].image!.url,
        progressCallback: (value) {
          if (i == 0) {
            loadImageStreamController.add(value);
          }
        },
        updateTexture: (imageInfo, s) {
          if (i == 0) {
            _updateTexture(imageInfo, s);
          }
        },
      ));

      _streamController.add(null);
    }
  }

  void _loadTexture(bool isNetwork, String? url) {
    if (url == null) return;
    clientTextures = [
      ClientTexture(
          isNetwork: isNetwork, imageUrl: url, updateTexture: _updateTexture)
    ];
  }

  void _updateTexture(ImageInfo imageInfo, bool synchronousCall) async {
    if (synchronousCall) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    surface?.mesh.texture = imageInfo.image;
    surface?.mesh.textureRect = Rect.fromLTWH(0, 0,
        imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
    scene!.texture = imageInfo.image;
    scene!.update();
    showHotspot = true;
    _streamController.add(null);
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
    widget.onViewChanged?.call(degrees(o.x), degrees(-o.y), vtProject);
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
