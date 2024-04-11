import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class AxesHelper extends LineSegments {
  AxesHelper.create({num size = 1, BufferGeometry? geometry, Material? material}):super(geometry, material){
    type = "AxesHelper";
  }
  
  factory AxesHelper([num size = 1]) {
    List<double> vertices = [
      0,
      0,
      0,
      size.toDouble(),
      0,
      0,
      0,
      0,
      0,
      0,
      size.toDouble(),
      0,
      0,
      0,
      0,
      0,
      0,
      size.toDouble()
    ];

    List<double> colors = [
      1,
      0,
      0,
      1,
      0.6,
      0,
      0,
      1,
      0,
      0.6,
      1,
      0,
      0,
      0,
      1,
      0,
      0.6,
      1
    ];

    final geometry = BufferGeometry();
    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute(
        'color',
        Float32BufferAttribute(Float32Array.from(colors), 3, false));

    final material =
        LineBasicMaterial({"vertexColors": true, "toneMapped": false});

    return AxesHelper.create(
        size: size, geometry: geometry, material: material);
  }

  AxesHelper setColors(Color xAxisColor, Color yAxisColor, Color zAxisColor) {
    final color = Color(1, 1, 1);
    final array = geometry!.attributes["color"].array;

    color.copy(xAxisColor);
    color.toArray(array, 0);
    color.toArray(array, 3);

    color.copy(yAxisColor);
    color.toArray(array, 6);
    color.toArray(array, 9);

    color.copy(zAxisColor);
    color.toArray(array, 12);
    color.toArray(array, 15);

    geometry!.attributes["color"].needsUpdate = true;

    return this;
  }

  @override
  void dispose() {
    geometry!.dispose();
    material.dispose();
  }
}
