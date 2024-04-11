import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

final spotLightHelperVector = Vector3();

class SpotLightHelper extends Object3D {
  late Light light;
  late Color? color;
  late LineSegments cone;

  SpotLightHelper(this.light, this.color) : super() {
    matrixAutoUpdate = false;
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;

    final geometry = BufferGeometry();

    List<double> positions = [
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      0,
      1,
      0,
      0,
      0,
      -1,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      1,
      0,
      0,
      0,
      0,
      -1,
      1
    ];

    for (int i = 0, j = 1, l = 32; i < l; i++, j++) {
      final p1 = (i / l) * Math.pi * 2;
      final p2 = (j / l) * Math.pi * 2;

      positions.addAll(
          [Math.cos(p1), Math.sin(p1), 1, Math.cos(p2), Math.sin(p2), 1]);
    }

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions), 3, false));

    final material = LineBasicMaterial({"fog": false, "toneMapped": false});

    cone = LineSegments(geometry, material);
    add(cone);

    update();
  }

  @override
  void dispose() {
    cone.geometry?.dispose();
    cone.material?.dispose();
  }

  void update() {
    light.updateMatrixWorld(false);

    double coneLength = light.distance ?? 1000;
    final coneWidth = coneLength * Math.tan(light.angle!);

    cone.scale.set(coneWidth, coneWidth, coneLength);

    spotLightHelperVector.setFromMatrixPosition(
        light.target!.matrixWorld);

    cone.lookAt(spotLightHelperVector);

    if (color != null) {
      cone.material.color.copy(color);
    } else {
      cone.material.color.copy(light.color);
    }
  }
}
