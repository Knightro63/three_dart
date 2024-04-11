import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light.dart';

class HemisphereLight extends Light {
  HemisphereLight(int? skyColor, int? groundColor, [double intensity = 1.0]):super(skyColor, intensity) {
    type = 'HemisphereLight';

    position.copy(Object3D.defaultUp);

    isHemisphereLight = true;
    updateMatrix();

    if (groundColor != null) {
      this.groundColor = Color.fromHex(groundColor);
    }
  }

  @override
  HemisphereLight copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    HemisphereLight source1 = source as HemisphereLight;

    groundColor!.copy(source1.groundColor!);

    return this;
  }
}
