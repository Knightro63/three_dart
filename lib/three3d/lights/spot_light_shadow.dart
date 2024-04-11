import 'package:three_dart/three3d/cameras/index.dart';
import 'package:three_dart/three3d/math/index.dart';

import 'light.dart';
import 'light_shadow.dart';

class SpotLightShadow extends LightShadow {
  SpotLightShadow() : super(PerspectiveCamera(50, 1, 0.5, 500)) {
    focus = 1;
  }

  @override
  void updateMatrices(Light light, {int viewportIndex = 0}) {
    PerspectiveCamera camera = this.camera as PerspectiveCamera;

    final fov = MathUtils.rad2deg * 2 * light.angle! * focus;
    final aspect = mapSize.width / mapSize.height;
    final far = light.distance ?? camera.far;

    if (fov != camera.fov || aspect != camera.aspect || far != camera.far) {
      camera.fov = fov;
      camera.aspect = aspect;
      camera.far = far;
      camera.updateProjectionMatrix();
    }

    super.updateMatrices(light, viewportIndex: viewportIndex);
  }

  @override
  SpotLightShadow copy(LightShadow source) {
    super.copy(source);

    focus = source.focus;

    return this;
  }
}
