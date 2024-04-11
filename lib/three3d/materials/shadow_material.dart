import './material.dart';
import '../math/index.dart';

class ShadowMaterial extends Material {
  ShadowMaterial([Map<String, dynamic>? parameters]) : super() {
    type = 'ShadowMaterial';
    color = Color.fromHex(0x000000);
    transparent = true;
    fog = true;
    setValues(parameters);
  }

  @override
  ShadowMaterial copy(Material source) {
    super.copy(source);

    color.copy(source.color);
    fog = source.fog;
    return this;
  }

  @override
  ShadowMaterial clone() {
    return ShadowMaterial().copy(this);
  }
}
