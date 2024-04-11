import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class GridHelper extends LineSegments {

  GridHelper.create(geometry, material) : super(geometry, material){
    type = 'GridHelper';
  }

  factory GridHelper([num size = 10, int divisions = 10, int color1 = 0x444444, int color2 = 0x888888]) {
    final color_1 = Color.fromHex(color1);
    final color_2 = Color.fromHex(color2);

    final center = divisions / 2;
    final step = size / divisions;
    final halfSize = size / 2;

    List<double> vertices = [];
    List<double> colors = List<double>.filled((divisions + 1) * 3 * 4, 0);
    double k = -halfSize;
    for (int i = 0, j = 0; i <= divisions; i++, k += step) {
      vertices.addAll([-halfSize, 0, k, halfSize, 0, k]);
      vertices.addAll([k, 0, -halfSize, k, 0, halfSize]);

      final color = (i == center) ? color_1 : color_2;

      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
    }

    final geometry = BufferGeometry();
    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute('color',
        Float32BufferAttribute(Float32Array.from(colors), 3, false));

    final material =
        LineBasicMaterial({"vertexColors": true, "toneMapped": false});

    return GridHelper.create(geometry, material);
  }
}
