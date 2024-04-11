import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class PlaneHelper extends Line {
  num size = 1.0;
  Plane? plane;

  PlaneHelper.create(geometry, material) : super(geometry, material){
    type = "PlaneHelper";
  }

  factory PlaneHelper(plane, [size = 1, hex = 0xffff00]) {
    final color = hex;

    List<double> positions = [
      1,
      -1,
      1,
      -1,
      1,
      1,
      -1,
      -1,
      1,
      1,
      1,
      1,
      -1,
      1,
      1,
      -1,
      -1,
      1,
      1,
      -1,
      1,
      1,
      1,
      1,
      0,
      0,
      1,
      0,
      0,
      0
    ];

    final geometry = BufferGeometry();
    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions), 3, false));
    geometry.computeBoundingSphere();

    final planeHelper = PlaneHelper.create(geometry, LineBasicMaterial({"color": color, "toneMapped": false}));

    planeHelper.plane = plane;
    planeHelper.size = size;

    List<double> positions2 = [
      1,
      1,
      1,
      -1,
      1,
      1,
      -1,
      -1,
      1,
      1,
      1,
      1,
      -1,
      -1,
      1,
      1,
      -1,
      1
    ];

    final geometry2 = BufferGeometry();
    geometry2.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions2), 3, false));
    geometry2.computeBoundingSphere();

    planeHelper.add(Mesh(
        geometry2,
        MeshBasicMaterial({
          "color": color,
          "opacity": 0.2,
          "transparent": true,
          "depthWrite": false,
          "toneMapped": false
        })));

    return planeHelper;
  }

  @override
  void updateMatrixWorld([bool force = false]) {
    double scale = -plane!.constant;

    if (Math.abs(scale) < 1e-8) scale = 1e-8; // sign does not matter

    this.scale.set(0.5 * size, 0.5 * size, scale);

    children[0].material.side = (scale < 0)
        ? BackSide
        : FrontSide; // renderer flips side when determinant < 0; flipping not wanted here

    lookAt(plane!.normal);

    super.updateMatrixWorld(force);
  }
}
