import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';

enum IconType { info, movement }

// ignore: must_be_immutable
class HotspotButton extends StatefulWidget {
  HotspotButton({
    Key? key,
    required this.icon,
    required this.iconType,
    this.onPressed,
    this.title,
    this.descriptions,
    this.callbackMovement,
    this.isShowControl = false,
    this.callbackDeleteLable,
    this.imageUrl,
    this.videoUrl,
    required this.offStage,
  }) : super(key: key);
  final Widget icon;
  final IconType iconType;
  final Function()? onPressed;
  final String? title;
  final String? descriptions;
  final String? imageUrl;
  final String? videoUrl;
  final Function()? callbackMovement;
  final Function()? callbackDeleteLable;
  final bool offStage;
  bool isShowControl;

  @override
  State<HotspotButton> createState() => _HotspotButtonState();
}

class _HotspotButtonState extends State<HotspotButton>
    with TickerProviderStateMixin {
  bool isShowInfo = false;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  final StreamController<bool> showDeleteController =
      StreamController<bool>.broadcast();
  final StreamController<bool> initVideoController =
      StreamController<bool>.broadcast();
  //YoutubePlayerController? _youtubeController;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));
    if (widget.videoUrl != null) {
      _videoController = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          initVideoController.add(true);
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offStage) {
      if (_videoController != null) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        }
      }
    }
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
                              Html(data: widget.title ?? "", style: {
                                "body": Style(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    color: Colors.white,
                                    fontSize: const FontSize(16),
                                    fontWeight: FontWeight.w600),
                                "p": Style(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                )
                              }),
                              const SizedBox(height: 10),
                              if (widget.descriptions != null)
                                Html(data: widget.descriptions ?? "", style: {
                                  "body": Style(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    color: Colors.white,
                                    fontSize: const FontSize(14),
                                  ),
                                  "p": Style(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                  )
                                }),
                              if (widget.imageUrl != null)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(widget.imageUrl!)),
                              if (widget.videoUrl != null)
                                StreamBuilder<bool>(
                                  initialData: false,
                                  stream: initVideoController.stream,
                                  builder: (context, snapshot) {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            color: Colors.black,
                                            child: snapshot.data!
                                                ? VideoPlayerHotspot(
                                                    videoController:
                                                        _videoController)
                                                : const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(
                                                      valueColor:
                                                          AlwaysStoppedAnimation(
                                                              Colors.white),
                                                    ),
                                                  ),
                                          ),
                                        ));
                                  },
                                ),
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
          child: widget.icon,
          onLongPress: () {
            showDeleteController.add(true);
          },
          onPressed: () {
            showDeleteController.add(false);
            if (widget.iconType == IconType.movement) {
              widget.callbackMovement!();
            } else {
              if (controller.isCompleted) {
                controller.reverse();
                if (_videoController != null) {
                  if (_videoController!.value.isInitialized) {
                    _videoController!.pause();
                  }
                }
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

class VideoPlayerHotspot extends StatefulWidget {
  const VideoPlayerHotspot({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  State<VideoPlayerHotspot> createState() => _VideoPlayerHotspotState();
}

class _VideoPlayerHotspotState extends State<VideoPlayerHotspot> {
  StreamController<int> positionController = StreamController.broadcast();
  StreamController<bool> playPauseController = StreamController.broadcast();
  @override
  void initState() {
    super.initState();
    if (widget._videoController != null) {
      listener = () {
        if (!mounted) {
          return;
        }
        final pos = widget._videoController!.value.position.inSeconds;
        final playPause = widget._videoController!.value.isPlaying;
        positionController.add(pos);
        playPauseController.add(playPause);
      };
      widget._videoController!.addListener(listener!);
    }
  }

  VoidCallback? listener;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._videoController == null) {
      return const Center(
          child: Text("Video playback error",
              style: TextStyle(color: Colors.white)));
    } else {
      final dur = widget._videoController!.value.duration.inSeconds;

      var totalDuration =
          "${(dur / 60).floor()}:${(dur % 60).toString().padLeft(2, '0')}";
      return Stack(
        children: [
          VideoPlayer(widget._videoController!),
          Center(
            child: StreamBuilder<bool>(
              initialData: false,
              stream: playPauseController.stream,
              builder: (context, snapshot) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: snapshot.data! ? 0 : 1,
                  child: Icon(
                      snapshot.data!
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 50.0),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget._videoController!.value.isPlaying) {
                widget._videoController!.pause();
              } else {
                widget._videoController!.play();
              }
            },
          ),
          Positioned(
              bottom: 5,
              left: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: StreamBuilder<int>(
                        initialData: 0,
                        stream: positionController.stream,
                        builder: (context, snapshot) {
                          var s =
                              "${(snapshot.data! / 60).floor()}:${(snapshot.data! % 60).toString().padLeft(2, '0')}";
                          return Text(s,
                              style: const TextStyle(
                                  fontSize: 8, color: Colors.white));
                        },
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: VideoProgressIndicator(
                              widget._videoController!,
                              padding: EdgeInsets.zero,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                  backgroundColor: Colors.black26,
                                  bufferedColor: Colors.grey,
                                  playedColor: Colors.white),
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(totalDuration,
                          style: const TextStyle(
                              fontSize: 8, color: Colors.white)),
                    ),
                  ],
                ),
              ))
        ],
      );
    }
  }
}
