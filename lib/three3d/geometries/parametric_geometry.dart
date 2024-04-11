import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';

/// Parametric Surfaces Geometry
/// based on the brilliant article by @prideout https://prideout.net/blog/old/blog/index.html@p=44.html

class ParametricGeometry extends BufferGeometry {
  ParametricGeometry(Function(double,double,Vector3) func, int slices, int stacks) : super() {
    type = "ParametricGeometry";
    parameters = {"func": func, "slices": slices, "stacks": stacks};

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    final eps = 0.00001;

    final normal = Vector3();

    final p0 = Vector3(), p1 = Vector3();
    final pu = Vector3(), pv = Vector3();

    // if ( func.length < 3 ) {

    // 	print( 'THREE.ParametricGeometry: Function must now modify a Vector3 as third parameter.' );

    // }

    // generate vertices, normals and uvs

    final sliceCount = slices + 1;

    for (int i = 0; i <= stacks; i++) {
      final v = i / stacks;

      for (int j = 0; j <= slices; j++) {
        final u = j / slices;

        // vertex

        func(u, v, p0);
        vertices.addAll([p0.x.toDouble(), p0.y.toDouble(), p0.z.toDouble()]);

        // normal

        // approximate tangent vectors via finite differences

        if (u - eps >= 0) {
          func(u - eps, v, p1);
          pu.subVectors(p0, p1);
        } else {
          func(u + eps, v, p1);
          pu.subVectors(p1, p0);
        }

        if (v - eps >= 0) {
          func(u, v - eps, p1);
          pv.subVectors(p0, p1);
        } else {
          func(u, v + eps, p1);
          pv.subVectors(p1, p0);
        }

        // cross product of tangent vectors returns surface normal

        normal.crossVectors(pu, pv).normalize();
        normals.addAll(
            [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

        // uv

        uvs.addAll([u, v]);
      }
    }

    // generate indices

    for (int i = 0; i < stacks; i++) {
      for (int j = 0; j < slices; j++) {
        final a = i * sliceCount + j;
        final b = i * sliceCount + j + 1;
        final c = (i + 1) * sliceCount + j + 1;
        final d = (i + 1) * sliceCount + j;

        // faces one and two

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
}
