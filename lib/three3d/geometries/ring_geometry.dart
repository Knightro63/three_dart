import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';

class RingGeometry extends BufferGeometry {
  RingGeometry([
    double innerRadius = 0.5,
    double outerRadius = 1,
    num thetaSegments = 8,
    num phiSegments = 1,
    num thetaStart = 0,
    double thetaLength = Math.pi * 2
  ]): super() {
    type = 'RingGeometry';
    parameters = {
      "innerRadius": innerRadius,
      "outerRadius": outerRadius,
      "thetaSegments": thetaSegments,
      "phiSegments": phiSegments,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    thetaSegments = Math.max<num>(3, thetaSegments);
    phiSegments = Math.max<num>(1, phiSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // some helper variables

    double radius = innerRadius;
    final radiusStep = ((outerRadius - innerRadius) / phiSegments);
    final vertex = Vector3();
    final uv = Vector2();

    // generate vertices, normals and uvs

    for (int j = 0; j <= phiSegments; j++) {
      for (int i = 0; i <= thetaSegments; i++) {
        // values are generate from the inside of the ring to the outside

        final segment = thetaStart + i / thetaSegments * thetaLength;

        // vertex

        vertex.x = radius * Math.cos(segment);
        vertex.y = radius * Math.sin(segment);

        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        normals.addAll([0, 0, 1]);

        // uv

        uv.x = (vertex.x / outerRadius + 1) / 2;
        uv.y = (vertex.y / outerRadius + 1) / 2;

        uvs.addAll([uv.x.toDouble(), uv.y.toDouble()]);
      }

      // increase the radius for next row of vertices

      radius += radiusStep;
    }

    // indices

    for (int j = 0; j < phiSegments; j++) {
      final thetaSegmentLevel = j * (thetaSegments + 1);
      for (int i = 0; i < thetaSegments; i++) {
        final segment = i + thetaSegmentLevel;

        final a = segment;
        final b = segment + thetaSegments + 1;
        final c = segment + thetaSegments + 2;
        final d = segment + 1;

        // faces

        indices.addAll([a, b, d]);
        indices.addAll([b, c, d]);
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute(
        'position', Float32BufferAttribute(Float32Array.from(vertices), 3));
    setAttribute(
        'normal', Float32BufferAttribute(Float32Array.from(normals), 3));
    setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2));
  }

  static fromJSON(data) {
    return RingGeometry(
        data.innerRadius,
        data.outerRadius,
        data.thetaSegments,
        data.phiSegments,
        data.thetaStart,
        data.thetaLength);
  }
}
