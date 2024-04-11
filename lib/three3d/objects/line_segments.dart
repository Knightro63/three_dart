import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import './line.dart';

final _lsstart = Vector3();
final _lsend = Vector3();

class LineSegments extends Line {
  LineSegments(BufferGeometry? geometry, Material? material) : super(geometry, material) {
    type = 'LineSegments';
  }

  @override
  LineSegments computeLineDistances() {
    final geometry = this.geometry;

    if (geometry != null) {
      // we assume non-indexed geometry

      if (geometry.index == null) {
        final positionAttribute = geometry.attributes["position"];
        final lineDistances = Float32Array(positionAttribute.count);

        for (int i = 0, l = positionAttribute.count; i < l; i += 2) {
          _lsstart.fromBufferAttribute(positionAttribute, i);
          _lsend.fromBufferAttribute(positionAttribute, i + 1);

          lineDistances[i] = (i == 0) ? 0 : lineDistances[i - 1];
          lineDistances[i + 1] = lineDistances[i] + _lsstart.distanceTo(_lsend);
        }

        geometry.setAttribute(
            'lineDistance', Float32BufferAttribute(lineDistances, 1, false));
      } 
      else {
        print('THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.');
      }
    }
    // else if (geometry.isGeometry) {
    //   throw ('THREE.LineSegments.computeLineDistances() no longer supports THREE.Geometry. Use THREE.BufferGeometry instead.');
    // }

    return this;
  }
}
