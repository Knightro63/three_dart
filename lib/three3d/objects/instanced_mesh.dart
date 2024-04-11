import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import './mesh.dart';

final _instanceLocalMatrix = Matrix4();
final _instanceWorldMatrix = Matrix4();

List<Intersection> _instanceIntersects = [];

final _mesh = Mesh(BufferGeometry(), Material());

class InstancedMesh extends Mesh {


  InstancedMesh(BufferGeometry? geometry, Material? material, int count): super(geometry, material) {
    type = "InstancedMesh";

    final dl = Float32Array(count * 16);
    instanceMatrix = InstancedBufferAttribute(dl, 16, false);
    instanceColor = null;

    this.count = count;

    frustumCulled = false;
  }

  @override
  InstancedMesh copy(Object3D source, [bool? recursive]) {
    super.copy(source);
    if (source is InstancedMesh) {
      instanceMatrix!.copy(source.instanceMatrix!);
      if (source.instanceColor != null) {
        instanceColor = source.instanceColor!.clone();
      }
      count = source.count;
    }
    return this;
  }

  Color getColorAt(int index, Color color) {
    return color.fromArray(instanceColor!.array.data, index * 3);
  }

  Matrix4 getMatrixAt(int index, Matrix4 matrix) {
    return matrix.fromArray(instanceMatrix!.array, index * 16);
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    final matrixWorld = this.matrixWorld;
    final raycastTimes = count;

    _mesh.geometry = geometry;
    _mesh.material = material;

    if (_mesh.material == null) return;

    for (int instanceId = 0; instanceId < raycastTimes!; instanceId++) {
      // calculate the world matrix for each instance

      getMatrixAt(instanceId, _instanceLocalMatrix);

      _instanceWorldMatrix.multiplyMatrices(matrixWorld, _instanceLocalMatrix);

      // the mesh represents this single instance

      _mesh.matrixWorld = _instanceWorldMatrix;

      _mesh.raycast(raycaster, _instanceIntersects);

      // process the result of raycast

      for (int i = 0, l = _instanceIntersects.length; i < l; i++) {
        final intersect = _instanceIntersects[i];
        intersect.instanceId = instanceId;
        intersect.object = this;
        intersects.add(intersect);
      }

      _instanceIntersects.length = 0;
    }
  }

  void setColorAt(int index, Color color) {
    instanceColor ??= InstancedBufferAttribute(
        Float32Array((instanceMatrix!.count * 3).toInt()), 3, false);

    return color.toArray(instanceColor!.array, index * 3);
  }

  void setMatrixAt(int index, Matrix4 matrix) {
    matrix.toArray(instanceMatrix!.array.toDartList(), index * 16);
  }

  @override
  void updateMorphTargets() {}

  @override
  void dispose() {
    dispatchEvent(Event(type: "dispose"));
  }
}
