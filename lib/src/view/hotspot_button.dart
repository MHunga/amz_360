import 'package:amz_360/src/view/menu_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'edit_hotspot_dialog.dart';

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
  }) : super(key: key);
  final ControlIcon icon;
  final Function()? onPressed;
  final String? title;
  final String? descriptions;
  final int? idImage;
  final Function(int)? callbackMovement;
  bool isShowControl;

  @override
  State<HotspotButton> createState() => _HotspotButtonState();
}

class _HotspotButtonState extends State<HotspotButton>
    with TickerProviderStateMixin {
  bool isShowInfo = false;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.title ?? "",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              if (widget.isShowControl)
                                const SizedBox(width: 24),
                              if (widget.isShowControl)
                                InkWell(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          EditInfoHotspotDialog(),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                    ),
                                  ),
                                )
                            ]),
                        const SizedBox(height: 10),
                        Text(widget.descriptions ?? "",
                            style: const TextStyle(fontSize: 14)),
                      ],
                    )),
              ),
            );
          }),
    );
  }

  Widget button() {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        shape: MaterialStateProperty.all(const CircleBorder()),
        // backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
      child: widget.icon.child,
      onPressed: () {
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
    );
  }
}
