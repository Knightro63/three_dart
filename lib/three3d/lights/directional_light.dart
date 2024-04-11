import 'package:three_dart/three3d/core/index.dart';
import 'light.dart';
import 'directional_light_shadow.dart';

class DirectionalLight extends Light {
  bool isDirectionalLight = true;

  DirectionalLight(int? color, [double? intensity]) : super(color, intensity) {
    type = "DirectionalLight";
    position.copy(Object3D.defaultUp);
    updateMatrix();
    target = Object3D();
    shadow = DirectionalLightShadow();
  }

  @override
  DirectionalLight copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    if (source is DirectionalLight) {
      target = source.target!.clone(false);
      shadow = source.shadow!.clone();
    }
    return this;
  }

  @override
  void dispose() {
    shadow!.dispose();
  }
}