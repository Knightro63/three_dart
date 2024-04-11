import 'package:three_dart/three3d/cameras/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/index.dart';
import 'light.dart';

class LightShadow {
  Camera? camera;

  num bias = 0;
  num normalBias = 0;
  num radius = 1;
  num blurSamples = 8;

  Vector2 mapSize = Vector2(512, 512);

  RenderTarget? map;
  RenderTarget? mapPass;
  Matrix4 matrix = Matrix4();

  bool autoUpdate = true;
  bool needsUpdate = false;

  final Frustum frustum = Frustum();
  final frameExtents = Vector2(1, 1);
  int viewportCount = 1;
  final List<Vector4> viewports = [Vector4(0, 0, 1, 1)];

  final Matrix4 projScreenMatrix = Matrix4();
  final Vector3 lightPositionWorld = Vector3();
  final Vector3 lookTarget = Vector3();

  late num focus;

  LightShadow(this.camera);

  LightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON);

  num getViewportCount() {
    return viewportCount;
  }

  Frustum getFrustum() {
    return frustum;
  }

  void updateMatrices(Light light, {int viewportIndex = 0}) {
    final shadowCamera = camera;
    final shadowMatrix = matrix;

    final lightPositionWorld = this.lightPositionWorld;

    lightPositionWorld.setFromMatrixPosition(light.matrixWorld);
    shadowCamera!.position.copy(lightPositionWorld);

    lookTarget.setFromMatrixPosition(light.target!.matrixWorld);
    shadowCamera.lookAt(lookTarget);
    shadowCamera.updateMatrixWorld(false);

    projScreenMatrix.multiplyMatrices(
        shadowCamera.projectionMatrix, shadowCamera.matrixWorldInverse);
    frustum.setFromProjectionMatrix(projScreenMatrix);

    shadowMatrix.set(0.5, 0.0, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.5, 0.5,
        0.0, 0.0, 0.0, 1.0);

    shadowMatrix.multiply(shadowCamera.projectionMatrix);
    shadowMatrix.multiply(shadowCamera.matrixWorldInverse);
  }

  Vector4 getViewport(int viewportIndex) {
    return viewports[viewportIndex];
  }

  Vector2 getFrameExtents() {
    return frameExtents;
  }

  LightShadow copy(LightShadow source) {
    camera = source.camera?.clone();

    bias = source.bias;
    radius = source.radius;

    mapSize.copy(source.mapSize);

    return this;
  }

  LightShadow clone() {
    return LightShadow(null).copy(this);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> object = {};

    if (bias != 0) object["bias"] = bias;
    if (normalBias != 0) object["normalBias"] = normalBias;
    if (radius != 1) object["radius"] = radius;
    if (mapSize.x != 512 || mapSize.y != 512) {
      object["mapSize"] = mapSize.toArray();
    }

    object["camera"] = camera!.toJSON()["object"];

    return object;
  }

  void dispose() {
    if (map != null) {
      map!.dispose();
    }

    if (mapPass != null) {
      mapPass!.dispose();
    }
  }
}
