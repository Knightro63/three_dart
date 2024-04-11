import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class PolarGridHelper extends LineSegments {
  PolarGridHelper.create(geomertey, material) : super(geomertey, material);

  factory PolarGridHelper([
    radius = 10,
    radials = 16,
    circles = 8,
    divisions = 64,
    int color1 = 0x444444,
    int color2 = 0x888888
  ]) {
    Color clr1 = Color(color1);
    Color clr2 = Color(color2);

    List<double> vertices = [];
    List<double> colors = [];

    // create the radials

    for (int i = 0; i <= radials; i++) {
      final v = (i / radials) * (Math.pi * 2);

      final x = Math.sin(v) * radius;
      final z = Math.cos(v) * radius;

      vertices.addAll([0, 0, 0]);
      vertices.addAll([x, 0, z]);

      final color = ((i & 1) != 0) ? clr1 : clr2;

      colors.addAll([color.r, color.g, color.b]);
      colors.addAll([color.r, color.g, color.b]);
    }

    // create the circles

    for (int i = 0; i <= circles; i++) {
      final color = ((i & 1) != 0) ? clr1 : clr2;
      final r = radius - (radius / circles * i);

      for (int j = 0; j < divisions; j++) {
        // first vertex

        double v = (j / divisions) * (Math.pi * 2);

        double x = Math.sin(v) * r;
        double z = Math.cos(v) * r;

        vertices.addAll([x, 0, z]);
        colors.addAll([color.r, color.g, color.b]);

        // second vertex

        v = ((j + 1) / divisions) * (Math.pi * 2);

        x = Math.sin(v) * r;
        z = Math.cos(v) * r;

        vertices.addAll([x, 0, z]);
        colors.addAll([color.r, color.g, color.b]);
      }
    }

    final geometry = BufferGeometry();
    geometry.setAttribute(
        'position', Float32BufferAttribute(Float32Array.from(vertices), 3));
    geometry.setAttribute(
        'color', Float32BufferAttribute(Float32Array.from(colors), 3));

    final material =
        LineBasicMaterial({"vertexColors": true, "toneMapped": false});

    final pgh = PolarGridHelper.create(geometry, material);

    pgh.type = 'PolarGridHelper';
    return pgh;
  }
}
