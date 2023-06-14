import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart';

class GridHelper extends LineSegments {
  GridHelper.create(geometry, material) : super(geometry, material) {
    type = 'GridHelper';
  }

  factory GridHelper([
    size = 10,
    int divisions = 10,
    color1 = 0x444444,
    color2 = 0x888888,
  ]) {
    var color_1 = Color.fromHex(color1);
    var color_2 = Color.fromHex(color2);

    var center = divisions / 2;
    var step = size / divisions;
    var halfSize = size / 2;

    List<double> vertices = [];
    List<double> colors = List<double>.filled((divisions + 1) * 3 * 4, 0);

    for (var i = 0, j = 0, k = -halfSize; i <= divisions; i++, k += step) {
      vertices.addAll([-halfSize, 0, k, halfSize, 0, k]);
      vertices.addAll([k, 0, -halfSize, k, 0, halfSize]);

      var color = (i == center) ? color_1 : color_2;

      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
      color.toArray(colors, j);
      j += 3;
    }

    var geometry = BufferGeometry();
    geometry.setAttribute(AttributeTypes.position, Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute(AttributeTypes.color, Float32BufferAttribute(Float32Array.from(colors), 3, false));

    var material = LineBasicMaterial({"vertexColors": true, "toneMapped": false});

    return GridHelper.create(geometry, material);
  }
}
