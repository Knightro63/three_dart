import 'package:three_dart/three_dart.dart';

var _basePosition = Vector3();

var _skinIndex = Vector4();
var _skinWeight = Vector4();

var _vector = Vector3();
var _matrix = Matrix4();

class SkinnedMesh extends Mesh {
  String bindMode = "attached";
  Matrix4 bindMatrixInverse = Matrix4();

  SkinnedMesh(geometry, material) : super(geometry, material) {
    type = "SkinnedMesh";
    bindMatrix = Matrix4();
  }

  @override
  SkinnedMesh clone([bool? recursive]) {
    return SkinnedMesh(geometry!, material).copy(this, recursive);
  }

  @override
  SkinnedMesh copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    SkinnedMesh source1 = source as SkinnedMesh;

    bindMode = source1.bindMode;
    bindMatrix!.copy(source1.bindMatrix!);
    bindMatrixInverse.copy(source1.bindMatrixInverse);

    skeleton = source1.skeleton;

    return this;
  }

  void bind(Skeleton skeleton, [Matrix4? bindMatrix]) {
    this.skeleton = skeleton;

    if (bindMatrix == null) {
      updateMatrixWorld(true);

      this.skeleton!.calculateInverses();

      bindMatrix = matrixWorld;
    }

    this.bindMatrix!.copy(bindMatrix);
    bindMatrixInverse.copy(bindMatrix).invert();
  }

  void pose() {
    skeleton!.pose();
  }

  void normalizeSkinWeights() {
    Vector4 vector = Vector4();

    var skinWeight = geometry!.attributes.skinWeightsBuffer!;

    for (int i = 0, l = skinWeight.count; i < l; i++) {
      vector.fromBufferAttribute(skinWeight, i);

      var scale = 1.0 / vector.manhattanLength();

      if (scale != double.infinity) {
        vector.multiplyScalar(scale);
      } else {
        vector.set(1, 0, 0, 0); // do something reasonable

      }

      skinWeight.setXYZW(i, vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble(), vector.w.toDouble());
    }
  }

  @override
  void updateMatrixWorld([bool force = false]) {
    super.updateMatrixWorld(force);

    if (bindMode == 'attached') {
      bindMatrixInverse.copy(matrixWorld).invert();
    } else if (bindMode == 'detached') {
      bindMatrixInverse.copy(bindMatrix!).invert();
    } else {
      print('three.SkinnedMesh: Unrecognized bindMode: $bindMode');
    }
  }

  Vector3 boneTransform(int index, Vector3 target) {
    Skeleton? skeleton = this.skeleton;
    BufferGeometry? geometry = this.geometry!;

    _skinIndex.fromBufferAttribute(geometry.attributes.skinIndexBuffer!, index);
    _skinWeight.fromBufferAttribute(geometry.attributes.skinWeightsBuffer!, index);

    _basePosition.copy(target).applyMatrix4(bindMatrix!);

    target.set(0, 0, 0);

    for (var i = 0; i < 4; i++) {
      var weight = _skinWeight.getComponent(i);

      if (weight != 0) {
        var boneIndex = _skinIndex.getComponent(i).toInt();

        _matrix.multiplyMatrices(skeleton!.bones[boneIndex].matrixWorld, skeleton.boneInverses[boneIndex]);

        target.addScaledVector(_vector.copy(_basePosition).applyMatrix4(_matrix), weight);
      }
    }

    return target.applyMatrix4(bindMatrixInverse);
  }

  @override
  Matrix4? getValue(String name) {
    if (name == "bindMatrix") {
      return bindMatrix;
    } else if (name == "bindMatrixInverse") {
      return bindMatrixInverse;
    } else {
      return super.getValue(name);
    }
  }
}
