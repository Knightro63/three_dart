import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class BoxGeometry extends BufferGeometry {
  late int groupStart;
  late int numberOfVertices;

  NativeArray? positionsArray;
  NativeArray? normalsArray;
  NativeArray? uvsArray;

  BoxGeometry([
    width = 1,
    height = 1,
    depth = 1,
    widthSegments = 1,
    heightSegments = 1,
    depthSegments = 1,
  ]) : super() {
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

    int wSeg = Math.floor(widthSegments);
    int hSeg = Math.floor(heightSegments);
    int dSeg = Math.floor(depthSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    numberOfVertices = 0;
    groupStart = 0;

    void buildPlane(String u, String v, String w, double udir, double vdir,
        width, height, depth, gridX, gridY, materialIndex) {
      double segmentWidth = width / gridX;
      double segmentHeight = height / gridY;

      double widthHalf = width / 2;
      double heightHalf = height / 2;
      double depthHalf = depth / 2;

      double gridX1 = gridX + 1;
      double gridY1 = gridY + 1;

      int vertexCounter = 0;
      int groupCount = 0;

      Vector3 vector = Vector3();

      // generate vertices, normals and uvs

      // print("buildPlane: u: ${u} v: ${v} w: ${w} udir: ${udir} vdir: ${vdir} width: ${width} height: ${height} depth: ${depth} gridX: ${gridX} gridY: ${gridY} materialIndex: ${materialIndex} ");

      for (int iy = 0; iy < gridY1; iy++) {
        double y = iy * segmentHeight - heightHalf;

        for (int ix = 0; ix < gridX1; ix++) {
          double x = ix * segmentWidth - widthHalf;

          // print("iy: ${iy} ix: ${ix} y: ${y} x: ${x} depthHalf: ${depthHalf} ");

          // set values to correct vector component

          // vector[ u ] = x * udir;
          // vector[ v ] = y * vdir;
          // vector[ w ] = depthHalf;

          vector.setP(u, x * udir);
          vector.setP(v, y * vdir);
          vector.setP(w, depthHalf);

          // now apply vector to vertex buffer

          vertices.addAll([vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

          // set values to correct vector component

          // vector[ u ] = 0;
          // vector[ v ] = 0;
          // vector[ w ] = depth > 0 ? 1 : - 1;

          vector.setP(u, 0);
          vector.setP(v, 0);
          vector.setP(w, depth > 0 ? 1 : -1);

          // now apply vector to normal buffer

          normals.addAll([vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

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
          double a = numberOfVertices + ix + gridX1 * iy;
          double b = numberOfVertices + ix + gridX1 * (iy + 1);
          double c = numberOfVertices + (ix + 1) + gridX1 * (iy + 1);
          double d = numberOfVertices + (ix + 1) + gridX1 * iy;

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

    buildPlane('z', 'y', 'x', -1, -1, depth, height, width, dSeg, hSeg, 0); // px
    buildPlane('z', 'y', 'x', 1, -1, depth, height, -width, dSeg, hSeg, 1); // nx
    buildPlane('x', 'z', 'y', 1, 1, width, depth, height, wSeg, dSeg, 2); // py
    buildPlane('x', 'z', 'y', 1, -1, width, depth, -height, wSeg, dSeg, 3); // ny
    buildPlane('x', 'y', 'z', 1, -1, width, height, depth, wSeg, hSeg, 4); // pz
    buildPlane('x', 'y', 'z', -1, -1, width, height, -depth, wSeg, hSeg, 5); // nz

    // build geometry

    setIndex(indices);
    setAttribute(AttributeTypes.position,Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute(AttributeTypes.normal, Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(AttributeTypes.uv, Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static fromJSON(data) {
    return BoxGeometry(
      data["width"],
      data["height"],
      data["depth"],
      data["widthSegments"],
      data["heightSegments"],
      data["depthSegments"],
    );
  }

  @override
  void dispose() {
    positionsArray?.dispose();
    normalsArray?.dispose();
    uvsArray?.dispose();

    super.dispose();
  }
}
