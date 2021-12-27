import 'package:amz_360/src/scene/mesh.dart';
import 'package:amz_360/src/scene/scene.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class Amz360Utils {
  static final Amz360Utils shared = Amz360Utils();
  final double _radius = 500;
  Vector3 quaternionToOrientation(Quaternion q) {
    // final Matrix4 m = Matrix4.compose(Vector3.zero(), q, Vector3.all(1.0));
    // final Vector v = motionSensors.getOrientation(m);
    // return Vector3(v.z, v.y, v.x);
    final storage = q.storage;
    final double x = storage[0];
    final double y = storage[1];
    final double z = storage[2];
    final double w = storage[3];
    final double roll =
        math.atan2(-2 * (x * y - w * z), 1.0 - 2 * (x * x + z * z));
    final double pitch = math.asin(2 * (y * z + w * x));
    final double yaw =
        math.atan2(-2 * (x * z - w * y), 1.0 - 2 * (x * x + y * y));
    return Vector3(yaw, pitch, roll);
  }

  Quaternion orientationToQuaternion(Vector3 v) {
    final Matrix4 m = Matrix4.identity();
    m.rotateZ(v.z);
    m.rotateX(v.y);
    m.rotateY(v.x);
    return Quaternion.fromRotation(m.getRotation());
  }

  Vector3 positionToLatLon(Scene scene, double x, double y) {
    // transform viewport coordinate to NDC, values between -1 and 1
    final Vector4 v = Vector4(2.0 * x / scene.camera.viewportWidth - 1.0,
        1.0 - 2.0 * y / scene.camera.viewportHeight, 1.0, 1.0);
    // create projection matrix
    final Matrix4 m = scene.camera.projectionMatrix * scene.camera.lookAtMatrix;
    // apply inversed projection matrix
    m.invert();
    v.applyMatrix4(m);
    // apply perspective division
    v.scale(1 / v.w);
    // get rotation from two vectors
    final Quaternion q =
        Quaternion.fromTwoVectors(v.xyz, Vector3(0.0, 0.0, -_radius));
    // get euler angles from rotation
    return quaternionToOrientation(
        q * Quaternion.axisAngle(Vector3(0, 1, 0), math.pi * 0.5));
  }

  Vector3 positionFromLatLon(Scene scene, double lat, double lon) {
    // create projection matrix
    final Matrix4 m = scene.camera.projectionMatrix *
        scene.camera.lookAtMatrix *
        matrixFromLatLon(lat, lon);
    // apply projection matrix
    final Vector4 v = Vector4(0.0, 0.0, -_radius, 1.0)..applyMatrix4(m);
    // apply perspective division and transform NDC to the viewport coordinate
    return Vector3(
      (1.0 + v.x / v.w) * scene.camera.viewportWidth / 2,
      (1.0 - v.y / v.w) * scene.camera.viewportHeight / 2,
      v.z,
    );
  }

  Matrix4 matrixFromLatLon(double lat, double lon) {
    return Matrix4.rotationY(radians(90.0 - lon))..rotateX(radians(lat));
  }

  Mesh generateSphereMesh(
      {int latSegments = 32,
      int lonSegments = 64,
      ui.Image? texture,
      Rect croppedArea = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
      double croppedFullWidth = 1.0,
      double croppedFullHeight = 1.0}) {
    int count = (latSegments + 1) * (lonSegments + 1);
    List<Vector3> vertices = List<Vector3>.filled(count, Vector3.zero());
    List<Offset> texcoords = List<Offset>.filled(count, Offset.zero);
    List<Polygon> indices =
        List<Polygon>.filled(latSegments * lonSegments * 2, Polygon(0, 0, 0));

    int i = 0;
    for (int y = 0; y <= latSegments; ++y) {
      final double tv = y / latSegments;
      final double v =
          (croppedArea.top + croppedArea.height * tv) / croppedFullHeight;
      final double sv = math.sin(v * math.pi);
      final double cv = math.cos(v * math.pi);
      for (int x = 0; x <= lonSegments; ++x) {
        final double tu = x / lonSegments;
        final double u =
            (croppedArea.left + croppedArea.width * tu) / croppedFullWidth;
        vertices[i] = Vector3(_radius * math.cos(u * math.pi * 2.0) * sv,
            _radius * cv, _radius * math.sin(u * math.pi * 2.0) * sv);
        texcoords[i] = Offset(tu, 1.0 - tv);
        i++;
      }
    }

    i = 0;
    for (int y = 0; y < latSegments; ++y) {
      final int base1 = (lonSegments + 1) * y;
      final int base2 = (lonSegments + 1) * (y + 1);
      for (int x = 0; x < lonSegments; ++x) {
        indices[i++] = Polygon(base1 + x, base1 + x + 1, base2 + x);
        indices[i++] = Polygon(base1 + x + 1, base2 + x + 1, base2 + x);
      }
    }

    final Mesh mesh = Mesh(
        vertices: vertices,
        texcoords: texcoords,
        indices: indices,
        texture: texture);
    return mesh;
  }

  double convertXfromServer(double sx, double sy, double sz) {
    double rx = math.atan2(sz, sx);
    return -degrees(rx);
  }

  double convertYfromServer(double sx, double sy, double sz) {
    if (sy > 0) {
      double delta = math.sqrt((math.pow(sx, 2) + math.pow(sz, 2))) / sy;
      double ry = math.pi / 2 - math.atan(delta);
      return degrees(ry);
    } else if (sy < 0) {
      double delta = (math.sqrt((math.pow(sx, 2) + math.pow(sz, 2)))) / sy;
      double ry = -math.pi / 2 - math.atan(delta);
      return degrees(ry);
    } else {
      return 90;
    }
  }

  double convertXtoServer(double cx, double cy) {
    double rx = radians(-cx);
    double ry = radians(cy);
    if (cy > 0) {
      ry = math.pi / 2 - ry;
    } else {
      ry = -math.pi / 2 - ry;
    }
    final x = 4999 * math.cos(rx) * math.sin(ry);
    if (cx > 0 && cx <= 90 || cx < 0 && cx >= -90) {
      return x.abs();
    } else {
      return -x.abs();
    }
  }

  double convertYtoServer(double cy) {
    double ry = radians(cy);
    if (cy > 0) {
      ry = math.pi / 2 - ry;
      return (4999 * math.cos(ry)).abs();
    } else {
      ry = -math.pi / 2 - ry;
      return -(4999 * math.cos(ry)).abs();
    }
  }

  double convertZtoServer(double cx, double cy) {
    double rx = radians(-cx);
    double ry = radians(cy);
    if (cy > 0) {
      ry = math.pi / 2 - ry;
    } else {
      ry = -math.pi / 2 - ry;
    }
    final z = 4999 * math.sin(rx) * math.sin(ry);
    if (cx > 0) {
      return -z.abs();
    } else {
      return z.abs();
    }
  }
}
