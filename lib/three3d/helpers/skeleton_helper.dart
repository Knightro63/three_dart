import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';

final _shvector = Vector3();
final _boneMatrix = Matrix4();
final _matrixWorldInv = Matrix4();

class SkeletonHelper extends LineSegments {
  bool isSkeletonHelper = true;
  late dynamic root;
  late dynamic bones;

  SkeletonHelper.create(geometry, material) : super(geometry, material){
    type = 'SkeletonHelper';
    matrixAutoUpdate = false;
  }

  factory SkeletonHelper(object) {
    final bones = getBoneList(object);

    final geometry = BufferGeometry();

    List<double> vertices = [];
    List<double> colors = [];

    final color1 = Color(0, 0, 1);
    final color2 = Color(0, 1, 0);

    for (int i = 0; i < bones.length; i++) {
      final bone = bones[i];

      if (bone.parent != null && bone.parent!.type == "Bone") {
        vertices.addAll([0, 0, 0]);
        vertices.addAll([0, 0, 0]);
        colors.addAll(
            [color1.r.toDouble(), color1.g.toDouble(), color1.b.toDouble()]);
        colors.addAll(
            [color2.r.toDouble(), color2.g.toDouble(), color2.b.toDouble()]);
      }
    }

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute(
        'color',
        Float32BufferAttribute(Float32Array.from(colors), 3, false));

    final material = LineBasicMaterial({
      "vertexColors": true,
      "depthTest": false,
      "depthWrite": false,
      "toneMapped": false,
      "transparent": true
    });

    final keletonHelper = SkeletonHelper.create(geometry, material);

    keletonHelper.root = object;
    keletonHelper.bones = bones;

    keletonHelper.matrix = object.matrixWorld;

    return keletonHelper;
  }

  @override
  void updateMatrixWorld([bool force = false]) {
    final bones = this.bones;

    final geometry = this.geometry!;
    final position = geometry.getAttribute('position');

    _matrixWorldInv.copy(root.matrixWorld).invert();

    for (int i = 0, j = 0; i < bones.length; i++) {
      final bone = bones[i];

      if (bone.parent != null && bone.parent.type == "Bone") {
        _boneMatrix.multiplyMatrices(_matrixWorldInv, bone.matrixWorld);
        _shvector.setFromMatrixPosition(_boneMatrix);
        position.setXYZ(j, _shvector.x, _shvector.y, _shvector.z);

        _boneMatrix.multiplyMatrices(_matrixWorldInv, bone.parent.matrixWorld);
        _shvector.setFromMatrixPosition(_boneMatrix);
        position.setXYZ(j + 1, _shvector.x, _shvector.y, _shvector.z);

        j += 2;
      }
    }

    geometry.getAttribute('position').needsUpdate = true;

    super.updateMatrixWorld(force);
  }

  static List<Bone> getBoneList(Object3D? object) {
    List<Bone> boneList = [];

    if (object != null && object is Bone) {
      boneList.add(object);
    }

    for (int i = 0; i < (object?.children.length ?? 0); i++) {
      boneList.addAll(getBoneList(object!.children[i]));
    }

    return boneList;
  }
}


