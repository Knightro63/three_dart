import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import './mesh.dart';
import './skeleton.dart';

final _basePosition = Vector3();

final _skinIndex = Vector4.init();
final _skinWeight = Vector4.init();

final _vector = Vector3();
final _matrix = Matrix4();

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
    final vector = Vector4.init();
    final skinWeight = geometry!.attributes["skinWeight"];
    for (int i = 0, l = skinWeight.count; i < l; i++) {
      vector.fromBufferAttribute( skinWeight, i );
      final scale = 1.0 / vector.manhattanLength();
      if (scale != double.infinity) {
        vector.multiplyScalar(scale);
      } 
      else {
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
      print('THREE.SkinnedMesh: Unrecognized bindMode: $bindMode');
    }
  }

  Vector3 boneTransform(int index, Vector3 target) {
    final skeleton = this.skeleton;
    final geometry = this.geometry!;

    _skinIndex.fromBufferAttribute(geometry.attributes["skinIndex"], index);
    _skinWeight.fromBufferAttribute(geometry.attributes["skinWeight"], index);
    _basePosition.copy(target).applyMatrix4(bindMatrix!);
    target.set(0, 0, 0);

    for (int i = 0; i < 4; i++) {
      final weight = _skinWeight.getComponent(i);
      if (weight != 0) {
        final boneIndex = _skinIndex.getComponent(i).toInt();
        _matrix.multiplyMatrices(skeleton!.bones[boneIndex].matrixWorld,
            skeleton.boneInverses[boneIndex]);
        target.addScaledVector(
            _vector.copy(_basePosition).applyMatrix4(_matrix), weight);
      }
    }
    return target.applyMatrix4(bindMatrixInverse);
  }

  @override
  Matrix4? getValue(String name) {
    if (name == "bindMatrix") {
      return bindMatrix;
    } 
    else if (name == "bindMatrixInverse") {
      return bindMatrixInverse;
    } 
    else {
      return super.getValue(name);
    }
  }
}
