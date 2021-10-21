import 'dart:ui';
import 'package:flutter/widgets.dart' hide Image;
import 'package:vector_math/vector_math_64.dart';
import 'scene.dart';

typedef SceneCreatedCallback = void Function(Scene scene);

class ScenceView extends StatefulWidget {
  const ScenceView({
    Key? key,
    this.onSceneCreated,
  }) : super(key: key);

  final SceneCreatedCallback? onSceneCreated;

  @override
  _ScenceViewState createState() => _ScenceViewState();
}

class _ScenceViewState extends State<ScenceView> {
  late Scene scene;

  @override
  void initState() {
    super.initState();
    scene = Scene(
      onUpdate: () => setState(() {}),
    );
    // prevent setState() or markNeedsBuild called during build
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onSceneCreated?.call(scene);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      scene.camera.viewportWidth = constraints.maxWidth;
      scene.camera.viewportHeight = constraints.maxHeight;
      final customPaint = CustomPaint(
        painter: _ScenePainter(scene),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
      return customPaint;
    });
  }
}

class _ScenePainter extends CustomPainter {
  final Scene _scene;
  const _ScenePainter(this._scene);

  @override
  void paint(Canvas canvas, Size size) {
    _scene.render(canvas, size);
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(_ScenePainter oldDelegate) {
    return true;
  }
}

/// Convert Offset to Vector2
Vector2 toVector2(Offset value) {
  return Vector2(value.dx, value.dy);
}
