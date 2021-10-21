import 'dart:async';

import 'package:flutter/material.dart';

class MenuControl extends StatefulWidget {
  final List<ControlIcon> children;
  final Function(ControlIcon?)? callbackSelected;
  const MenuControl({
    Key? key,
    required this.children,
    this.callbackSelected,
  }) : super(key: key);

  @override
  State<MenuControl> createState() => _MenuControlState();
}

class _MenuControlState extends State<MenuControl>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late StreamController<bool> _streamController;
  late Stream<bool> _stream;
  int? selectedIndex;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _streamController = StreamController.broadcast();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            _streamController.add(false);
          }
          return Stack(
            children: [
              ...List.generate(
                  widget.children.length,
                  (index) => snapshot.data != null
                      ? AnimatedPositioned(
                          top: snapshot.data! ? (50 * (index + 1)) : 0,
                          child: FadeTransition(
                            opacity: controller,
                            child: MenuAction(
                                isSelected: selectedIndex == index,
                                onTap: () {
                                  selectedIndex = index;
                                  _streamController.add(true);
                                  if (widget.callbackSelected != null) {
                                    widget.callbackSelected!(
                                        widget.children[index]);
                                  }
                                },
                                child: widget.children[index].child),
                          ),
                          duration: const Duration(milliseconds: 500))
                      : Container()),
              Column(
                children: [
                  MenuAction(
                    isSelected: false,
                    onTap: () {
                      if (snapshot.data!) {
                        controller.reverse();
                        _streamController.add(false);
                        selectedIndex = null;
                        if (widget.callbackSelected != null) {
                          widget.callbackSelected!(null);
                        }
                      } else {
                        controller.forward();
                        _streamController.add(true);
                      }
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: controller,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height)
                ],
              ),
            ],
          );
        });
  }
}

class MenuAction extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final bool isSelected;
  const MenuAction({
    Key? key,
    this.onTap,
    required this.child,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
        child: child,
        decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withOpacity(0.5)
                : const Color(0xff000000).withOpacity(0.5),
            border: isSelected ? Border.all(color: Colors.white) : null,
            borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

enum IconType { info, movement }

class ControlIcon {
  final IconType iconType;
  final Widget child;

  ControlIcon({this.iconType = IconType.info, required this.child});
}
