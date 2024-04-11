import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';

class BoxGeometry extends BufferGeometry {
  late int groupStart;
  late int numberOfVertices;

  BoxGeometry([
    double width = 1,
    double height = 1,
    double depth = 1,
    int widthSegments = 1,
    int heightSegments = 1,
    int depthSegments = 1
  ]):super() {
    type = "BoxGeometry";

    parameters = {
      "width": width,
      "height": height,
      "depth": depth,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments,
      "depthSegments": depthSegments
    };

    // segments

    // int _widthSegments = Math.floor(widthSegments);
    // int _heightSegments = Math.floor(heightSegments);
    // int _depthSegments = Math.floor(depthSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    numberOfVertices = 0;
    groupStart = 0;

    void buildPlane(String u, String v, String w, double udir, double vdir, num width, num height, num depth, num gridX, num gridY, int materialIndex) {
      final segmentWidth = width / gridX;
      final segmentHeight = height / gridY;

      final widthHalf = width / 2;
      final heightHalf = height / 2;
      final depthHalf = depth / 2;

      final gridX1 = gridX + 1;
      final gridY1 = gridY + 1;

      int vertexCounter = 0;
      int groupCount = 0;

      final vector = Vector3();

      // generate vertices, normals and uvs

      // print("buildPlane: u: ${u} v: ${v} w: ${w} udir: ${udir} vdir: ${vdir} width: ${width} height: ${height} depth: ${depth} gridX: ${gridX} gridY: ${gridY} materialIndex: ${materialIndex} ");

      for (int iy = 0; iy < gridY1; iy++) {
        final y = iy * segmentHeight - heightHalf;

        for (int ix = 0; ix < gridX1; ix++) {
          final x = ix * segmentWidth - widthHalf;

          // print("iy: ${iy} ix: ${ix} y: ${y} x: ${x} depthHalf: ${depthHalf} ");

          // set values to correct vector component

          // vector[ u ] = x * udir;
          // vector[ v ] = y * vdir;
          // vector[ w ] = depthHalf;

          vector.setP(u, x * udir);
          vector.setP(v, y * vdir);
          vector.setP(w, depthHalf);

          // now apply vector to vertex buffer

          vertices.addAll(
              [vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

          // set values to correct vector component

          // vector[ u ] = 0;
          // vector[ v ] = 0;
          // vector[ w ] = depth > 0 ? 1 : - 1;

          vector.setP(u, 0);
          vector.setP(v, 0);
          vector.setP(w, depth > 0 ? 1 : -1);

          // now apply vector to normal buffer

          normals.addAll(
              [vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

          // uvs

          uvs.add(ix / gridX);
          uvs.add(1 - (iy / gridY));

          // counters

          vertexCounter += 1;
        }
      }

      // indices

      // 1. you need three indices to draw a single face
      // 2. a single segment consists of two faces
      // 3. so we need to generate six (2*3) indices per segment

      for (int iy = 0; iy < gridY; iy++) {
        for (int ix = 0; ix < gridX; ix++) {
          final a = numberOfVertices + ix + gridX1 * iy;
          final b = numberOfVertices + ix + gridX1 * (iy + 1);
          final c = numberOfVertices + (ix + 1) + gridX1 * (iy + 1);
          final d = numberOfVertices + (ix + 1) + gridX1 * iy;

          // faces

          indices.addAll([a, b, d]);
          indices.addAll([b, c, d]);

          // increase counter

          groupCount += 6;
        }
      }

      // add a group to the geometry. this will ensure multi material support

      addGroup(groupStart, groupCount, materialIndex);

      // calculate new start value for groups

      groupStart += groupCount;

      // update total number of vertices

      numberOfVertices += vertexCounter;
    }

    // build each side of the box geometry

    buildPlane('z', 'y', 'x', -1, -1, depth, height, width, depthSegments,
        heightSegments, 0); // px
    buildPlane('z', 'y', 'x', 1, -1, depth, height, -width, depthSegments,
        heightSegments, 1); // nx
    buildPlane('x', 'z', 'y', 1, 1, width, depth, height, widthSegments,
        depthSegments, 2); // py
    buildPlane('x', 'z', 'y', 1, -1, width, depth, -height, widthSegments,
        depthSegments, 3); // ny
    buildPlane('x', 'y', 'z', 1, -1, width, height, depth, widthSegments,
        heightSegments, 4); // pz
    buildPlane('x', 'y', 'z', -1, -1, width, height, -depth, widthSegments,
        heightSegments, 5); // nz

    // build geometry

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static BoxGeometry fromJSON(Map<String,dynamic> data) {
    return BoxGeometry(data["width"], data["height"], data["depth"],
        data["widthSegments"], data["heightSegments"], data["depthSegments"]);
  }
}
