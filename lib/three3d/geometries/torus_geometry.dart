import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';

class TorusGeometry extends BufferGeometry {
  TorusGeometry([
    num radius = 1,
    double tube = 0.4,
    int radialSegments = 8,
    int tubularSegments = 6,
    double arc = Math.pi * 2
  ]):super() {
    type = "TorusGeometry";
    parameters = {
      "radius": radius,
      "tube": tube,
      "radialSegments": radialSegments,
      "tubularSegments": tubularSegments,
      "arc": arc
    };

    radialSegments = Math.floor(radialSegments);
    tubularSegments = Math.floor(tubularSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    final center = Vector3();
    final vertex = Vector3();
    final normal = Vector3();

    // generate vertices, normals and uvs

    for (int j = 0; j <= radialSegments; j++) {
      for (int i = 0; i <= tubularSegments; i++) {
        final u = i / tubularSegments * arc;
        final v = j / radialSegments * Math.pi * 2;

        // vertex

        vertex.x = (radius + tube * Math.cos(v)) * Math.cos(u);
        vertex.y = (radius + tube * Math.cos(v)) * Math.sin(u);
        vertex.z = tube * Math.sin(v);

        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        center.x = radius * Math.cos(u);
        center.y = radius * Math.sin(u);
        normal.subVectors(vertex, center).normalize();

        normals.addAll(
            [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

        // uv

        uvs.add(i / tubularSegments);
        uvs.add(j / radialSegments);

        if(i > 0 && j > 0){
          final a = (tubularSegments + 1) * j + i - 1;
          final b = (tubularSegments + 1) * (j - 1) + i - 1;
          final c = (tubularSegments + 1) * (j - 1) + i;
          final d = (tubularSegments + 1) * j + i;

          indices.addAll([a,b,d]);
          indices.addAll([b,c,d]);
        }
      }
    }

    // generate indices

    // for (int j = 1; j <= radialSegments; j++) {
    //   for (int i = 1; i <= tubularSegments; i++) {
    //     // indices

    //     final a = (tubularSegments + 1) * j + i - 1;
    //     final b = (tubularSegments + 1) * (j - 1) + i - 1;
    //     final c = (tubularSegments + 1) * (j - 1) + i;
    //     final d = (tubularSegments + 1) * j + i;

    //     // faces

    //     indices.addAll([a, b, d]);
    //     indices.addAll([b, c, d]);
    //   }
    // }

    // build geometry

    setIndex(indices);
    setAttribute(
        'position', Float32BufferAttribute(Float32Array.from(vertices), 3));
    setAttribute(
        'normal', Float32BufferAttribute(Float32Array.from(normals), 3));
    setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2));
  }

  static fromJSON(data) {
    return TorusGeometry(data.radius, data.tube, data.radialSegments,
        data.tubularSegments, data.arc);
  }
}
