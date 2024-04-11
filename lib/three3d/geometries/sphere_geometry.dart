import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';

class SphereGeometry extends BufferGeometry {
  SphereGeometry([
    num radius = 1,
    num widthSegments = 32,
    num heightSegments = 16,
    num phiStart = 0,
    double phiLength = Math.pi * 2,
    num thetaStart = 0,
    double thetaLength = Math.pi
  ]):super() {
    type = "SphereGeometry";
    parameters = {
      "radius": radius,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments,
      "phiStart": phiStart,
      "phiLength": phiLength,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    widthSegments = Math.max(3, Math.floor(widthSegments));
    heightSegments = Math.max(2, Math.floor(heightSegments));

    final thetaEnd = Math.min<num>(thetaStart + thetaLength, Math.pi);

    int index = 0;
    final grid = [];

    final vertex = Vector3();
    final normal = Vector3();

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // generate vertices, normals and uvs

    for (int iy = 0; iy <= heightSegments; iy++) {
      final verticesRow = [];

      final v = iy / heightSegments;

      // special case for the poles

      num uOffset = 0;

      if (iy == 0 && thetaStart == 0) {
        uOffset = 0.5 / widthSegments;
      } else if (iy == heightSegments && thetaEnd == Math.pi) {
        uOffset = -0.5 / widthSegments;
      }

      for (int ix = 0; ix <= widthSegments; ix++) {
        final u = ix / widthSegments;

        // vertex

        vertex.x = -radius *
            Math.cos(phiStart + u * phiLength) *
            Math.sin(thetaStart + v * thetaLength);
        vertex.y = radius * Math.cos(thetaStart + v * thetaLength);
        vertex.z = radius *
            Math.sin(phiStart + u * phiLength) *
            Math.sin(thetaStart + v * thetaLength);

        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        normal.copy(vertex).normalize();
        normals.addAll(
            [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

        // uv

        uvs.addAll([u + uOffset, 1 - v]);

        verticesRow.add(index++);
      }

      grid.add(verticesRow);
    }

    // indices

    for (int iy = 0; iy < heightSegments; iy++) {
      for (int ix = 0; ix < widthSegments; ix++) {
        final a = grid[iy][ix + 1];
        final b = grid[iy][ix];
        final c = grid[iy + 1][ix];
        final d = grid[iy + 1][ix + 1];

        if (iy != 0 || thetaStart > 0) indices.addAll([a, b, d]);
        if (iy != heightSegments - 1 || thetaEnd < Math.pi) {
          indices.addAll([b, c, d]);
        }
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static fromJSON(data) {
    return SphereGeometry(
        data["radius"],
        data["widthSegments"],
        data["heightSegments"],
        data["phiStart"],
        data["phiLength"],
        data["thetaStart"],
        data["thetaLength"]);
  }
}
