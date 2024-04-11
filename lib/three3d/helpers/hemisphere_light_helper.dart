import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/geometries/index.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

final _vectorHemisphereLightHelper = Vector3();
final _color1 = Color(0, 0, 0);
final _color2 = Color(0, 0, 0);

class HemisphereLightHelper extends Object3D {
  Color? color;
  late Light light;

  HemisphereLightHelper(this.light, size, this.color) : super() {
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;
    matrixAutoUpdate = false;

    final geometry = OctahedronGeometry(size);
    geometry.rotateY(Math.pi * 0.5);

    material = MeshBasicMaterial({"wireframe": true, "fog": false, "toneMapped": false});
    if (color == null) material.vertexColors = true;

    final position = geometry.getAttribute('position');
    final colors = Float32Array(position.count * 3);

    geometry.setAttribute('color', Float32BufferAttribute(colors, 3, false));
    add(Mesh(geometry, material));
    update();
  }

  @override
  void dispose() {
    children[0].geometry!.dispose();
    children[0].material.dispose();
  }

  void update() {
    final mesh = children[0];

    if (color != null) {
      material.color.copy(color);
    } else {
      final colors = mesh.geometry!.getAttribute('color');

      _color1.copy(light.color!);
      _color2.copy(light.groundColor!);

      for (int i = 0, l = colors.count; i < l; i++) {
        final color = (i < (l / 2)) ? _color1 : _color2;

        colors.setXYZ(i, color.r, color.g, color.b);
      }

      colors.needsUpdate = true;
    }

    mesh.lookAt(_vectorHemisphereLightHelper
        .setFromMatrixPosition(light.matrixWorld)
        .negate());
  }
}
