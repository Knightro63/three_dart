import 'package:three_dart/three3d/cameras/index.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light_shadow.dart';

class PointLightShadow extends LightShadow {
  late List<Vector3> _cubeDirections;
  late List<Vector3> _cubeUps;

  PointLightShadow():super(PerspectiveCamera(90, 1, 0.5, 500)) {
    frameExtents.copy(Vector2(4, 2));

    viewportCount = 6;
    
    viewports.removeAt(0);
    viewports.addAll([
      // These viewports map a cube-map onto a 2D texture with the
      // following orientation:
      //
      //  xzXZ
      //   y Y
      //
      // X - Positive x direction
      // x - Negative x direction
      // Y - Positive y direction
      // y - Negative y direction
      // Z - Positive z direction
      // z - Negative z direction

      // positive X
      Vector4(2, 1, 1, 1),
      // negative X
      Vector4(0, 1, 1, 1),
      // positive Z
      Vector4(3, 1, 1, 1),
      // negative Z
      Vector4(1, 1, 1, 1),
      // positive Y
      Vector4(3, 0, 1, 1),
      // negative Y
      Vector4(1, 0, 1, 1)
    ]);

    _cubeDirections = [
      Vector3(1, 0, 0),
      Vector3(-1, 0, 0),
      Vector3(0, 0, 1),
      Vector3(0, 0, -1),
      Vector3(0, 1, 0),
      Vector3(0, -1, 0)
    ];

    _cubeUps = [
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 0, 1),
      Vector3(0, 0, -1)
    ];
  }

  PointLightShadow.fromJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    camera = Object3D.castJSON(json["camera"], rootJSON) as Camera;
  }

  @override
  void updateMatrices(light, {viewportIndex = 0}) {
    final camera = this.camera;
    final shadowMatrix = matrix;

    final far = light.distance ?? camera!.far;

    if (far != camera!.far) {
      camera.far = far;
      camera.updateProjectionMatrix();
    }

    lightPositionWorld.setFromMatrixPosition(light.matrixWorld);
    camera.position.copy(lightPositionWorld);

    lookTarget.copy(camera.position);
    lookTarget.add(_cubeDirections[viewportIndex]);
    camera.up.copy(_cubeUps[viewportIndex]);
    camera.lookAt(lookTarget);
    camera.updateMatrixWorld(false);

    shadowMatrix.makeTranslation(
        -lightPositionWorld.x, -lightPositionWorld.y, -lightPositionWorld.z);

    projScreenMatrix.multiplyMatrices(
        camera.projectionMatrix, camera.matrixWorldInverse);
    frustum.setFromProjectionMatrix(projScreenMatrix);
  }
}
