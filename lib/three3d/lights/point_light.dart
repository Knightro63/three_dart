import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light.dart';
import 'point_light_shadow.dart';

class PointLight extends Light {
  PointLight(int? color, [double? intensity, double? distance, double? decay]):super(color, intensity) {
    // remove default 0  for js 0 is false  but for dart 0 is not.
    // PointLightShadow.updateMatrices  far value
    this.distance = distance;
    this.decay = decay ?? 1; // for physically correct lights, should be 2.

    shadow = PointLightShadow();
    type = "PointLight";
  }

  PointLight.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    type = "PointLight";
    distance = json["distance"];
    decay = json["decay"] ?? 1;
    shadow = PointLightShadow.fromJSON(json["shadow"], rootJSON);
  }

  get power {
    return intensity * 4 * Math.pi;
  }

  set power(value) {
    intensity = value / (4 * Math.pi);
  }

  @override
  PointLight copy(Object3D source, [bool? recursive]) {
    super.copy.call(source);

    PointLight source1 = source as PointLight;

    distance = source1.distance;
    decay = source1.decay;

    shadow = source1.shadow!.clone();

    return this;
  }

  @override
  void dispose() {
    shadow?.dispose();
  }
}
