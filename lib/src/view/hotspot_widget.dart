import 'package:amz_360/amz_360.dart';
import 'package:amz_360/src/models/vt_hotspot.dart';
import 'package:amz_360/src/scene/scene.dart';
import 'package:amz_360/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'hotspot_button.dart';

class HotspotWidget extends StatelessWidget {
  final Scene scene;
  final dynamic hotspot;
  final bool showControl;
  final Function() callbackRemove;
  final Function() callbackMovement;
  final int imageId;
  const HotspotWidget(
      {Key? key,
      required this.scene,
      this.hotspot,
      required this.showControl,
      required this.callbackRemove,
      required this.callbackMovement,
      required this.imageId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Vector3 pos =
        Amz360Utils.shared.positionFromLatLon(scene, hotspot.y!, hotspot.x!);
    const Offset orgin = Offset(30, 25);
    final Matrix4 transform = scene.camera.lookAtMatrix *
        Amz360Utils.shared.matrixFromLatLon(hotspot.y!, hotspot.x!);
    return pos.z > 0
        ? Positioned(
            left: pos.x - orgin.dx,
            top: pos.y - orgin.dy,
            child: Transform(
              origin: orgin,
              transform: transform..invert(),
              child: HotspotButton(
                isShowControl: showControl,
                callbackDeleteLable: () async {
                  if (hotspot is VTHotspotLable) {
                    await Amz360.instance
                        .deleteHotspotLable(
                            imageId: hotspot.imageId!, hotspotId: hotspot.id!)
                        .then((v) {
                      if (v) {
                        callbackRemove();
                      }
                    });
                  } else if (hotspot is VTHotspotLink) {
                    await Amz360.instance
                        .deleteHotspotToOtherImage(
                            imageId: imageId, hotspotId: hotspot.id!)
                        .then((v) {
                      if (v) {
                        callbackRemove();
                      }
                    });
                  }
                },
                icon: hotspot is VTHotspotLable
                    ? hotspot.icon ??
                        const Icon(Icons.info, color: Color(0xffffffff))
                    : hotspot is VTHotspotLink
                        ? hotspot.icon ??
                            const Icon(Icons.arrow_circle_up_rounded,
                                color: Color(0xffffffff))
                        : const Icon(Icons.info, color: Color(0xffffffff)),
                iconType: hotspot is VTHotspotLable
                    ? IconType.info
                    : IconType.movement,
                title: hotspot is VTHotspotLable ? hotspot.title : null,
                descriptions: hotspot is VTHotspotLable ? hotspot.text : null,
                imageUrl: hotspot is VTHotspotLable ? hotspot.imageUrl : null,
                videoIframe:
                    hotspot is VTHotspotLable ? hotspot.videoUrl : null,
                callbackMovement: () async {
                  if (hotspot is VTHotspotLink) {
                    callbackMovement();
                  }
                },
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
