import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/geometries/index.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class PointLightHelper extends Mesh{
  late PointLight light;
  Color? color;

  PointLightHelper.create(BufferGeometry? geometry, Material? material):super(geometry, material){
    type = "PointLightHelper";
  }

  factory PointLightHelper(light, sphereSize, Color color) {
    final geometry = SphereGeometry(sphereSize, 4, 2);
    final material = MeshBasicMaterial({"wireframe": true, "fog": false, "toneMapped": false});

    final plh = PointLightHelper.create(geometry, material);

    plh.light = light;
    plh.light.updateMatrixWorld(false);

    plh.color = color;
    plh.matrix = plh.light.matrixWorld;
    plh.matrixAutoUpdate = false;

    plh.update();
    return plh;
  }

  @override
  void dispose() {
    geometry?.dispose();
    material?.dispose();
  }

  void update() {
    if (color != null) {
      material.color.set(color);
    } 
    else {
      material.color.copy(light.color);
    }
  }
}
