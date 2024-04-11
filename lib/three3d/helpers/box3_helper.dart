import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

class Box3Helper extends LineSegments {
  Box3? box;

  Box3Helper.create(BufferGeometry? geometry, Material? material) : super(geometry, material);

  factory Box3Helper(Box3? box, [color = 0xffff00]) {
    final indices = Uint16Array.from([
      0,
      1,
      1,
      2,
      2,
      3,
      3,
      0,
      4,
      5,
      5,
      6,
      6,
      7,
      7,
      4,
      0,
      4,
      1,
      5,
      2,
      6,
      3,
      7
    ]);

    List<double> positions = [
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
      -1,
      -1,
      1,
      -1,
      -1,
      -1,
      -1,
      1,
      -1,
      -1
    ];

    final geometry = BufferGeometry();

    geometry.setIndex(Uint16BufferAttribute(indices, 1, false));

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions), 3, false));

    final box3Helper = Box3Helper.create(
        geometry, LineBasicMaterial({"color": color, "toneMapped": false}));

    box3Helper.box = box;

    box3Helper.type = 'Box3Helper';

    box3Helper.geometry!.computeBoundingSphere();

    return box3Helper;
  }

  @override
  void updateMatrixWorld([bool force = false]) {
    final box = this.box!;

    if (box.isEmpty()) return;

    box.getCenter(position);

    box.getSize(scale);

    scale.multiplyScalar(0.5);

    super.updateMatrixWorld(force);
  }
}
