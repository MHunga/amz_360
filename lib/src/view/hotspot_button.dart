import 'dart:async';

import 'package:amz_360/src/view/menu_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class HotspotButton extends StatefulWidget {
  HotspotButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.title,
    this.descriptions,
    this.callbackMovement,
    this.idImage,
    this.isShowControl = false,
    this.callbackDeleteLable,
    this.imageUrl,
    this.videoIframe,
  }) : super(key: key);
  final ControlIcon icon;
  final Function()? onPressed;
  final String? title;
  final String? descriptions;
  final String? imageUrl;
  final String? videoIframe;
  final int? idImage;
  final Function(int)? callbackMovement;
  final Function()? callbackDeleteLable;
  bool isShowControl;

  @override
  State<HotspotButton> createState() => _HotspotButtonState();
}

class _HotspotButtonState extends State<HotspotButton>
    with TickerProviderStateMixin {
  bool isShowInfo = false;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  StreamController<bool> showDeleteController = StreamController.broadcast();
  YoutubePlayerController? _youtubeController;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));
    if (widget.videoIframe != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: getIdFromEmbeded(widget.videoIframe!),
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [button(), info()],
    );
  }

  Widget info() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return ScaleTransition(
              scale: scaleAnimation,
              alignment: Alignment.topLeft,
              child: FadeTransition(
                opacity: scaleAnimation,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    constraints:
                        const BoxConstraints(maxWidth: 250, minWidth: 100),
                    margin: const EdgeInsets.only(top: 5, left: 10),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              if (widget.descriptions != null)
                                Text(widget.descriptions ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    )),
                              if (widget.imageUrl != null)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(widget.imageUrl!)),
                              if (widget.videoIframe != null)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: YoutubePlayer(
                                      controller: _youtubeController!,
                                      showVideoProgressIndicator: true,
                                    )),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            );
          }),
    );
  }

  Widget delete() {
    return ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.7)),
        onPressed: widget.callbackDeleteLable,
        child: const Icon(Icons.delete, size: 16));
  }

  Widget button() {
    return Row(
      children: [
        TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(const CircleBorder()),
            // backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          child: widget.icon.child,
          onLongPress: () {
            showDeleteController.add(true);
          },
          onPressed: () {
            showDeleteController.add(false);
            if (widget.icon.iconType == IconType.movement) {
              widget.callbackMovement!(widget.idImage!);
            } else {
              if (controller.isCompleted) {
                controller.reverse();
              } else {
                controller.forward();
              }
            }
          },
        ),
        if (widget.isShowControl)
          StreamBuilder<bool>(
            initialData: false,
            stream: showDeleteController.stream,
            builder: (context, snapshot) {
              if (snapshot.data!) {
                return delete();
              } else {
                return const SizedBox();
              }
            },
          )
      ],
    );
  }

  String getIdFromEmbeded(String videoIframe) {
    final l1 = videoIframe.split("embed/");
    final l2 = l1[1].split(r'"');
    return l2[0];
  }
}
