import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

import 'light.dart';
import 'spot_light_shadow.dart';

class SpotLight extends Light {
  SpotLight([int? color, double? intensity, double? distance, double? angle, double? penumbra, double? decay]):super(color, intensity) {
    type = "SpotLight";
    position.copy(Object3D.defaultUp);
    updateMatrix();

    target = Object3D();

    // remove default 0  for js 0 is false  but for dart 0 is not.
    // SpotLightShadow.updateMatrices  far value
    this.distance = distance;
    this.angle = angle ?? Math.pi / 3;
    this.penumbra = penumbra ?? 0;
    this.decay = decay ?? 1; // for physically correct lights, should be 2.

    shadow = SpotLightShadow();
  }

  double get power {
    return intensity * Math.pi;
  }

  set power(double value) {
    intensity = value / Math.pi;
  }

  @override
  SpotLight copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    SpotLight source1 = source as SpotLight;

    distance = source1.distance;
    angle = source1.angle;
    penumbra = source1.penumbra;
    decay = source1.decay;

    target = source1.target!.clone();

    shadow = source1.shadow!.clone();

    return this;
  }

  @override
  void dispose() {
    shadow!.dispose();
  }
}
