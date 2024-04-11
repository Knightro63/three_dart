import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light_shadow.dart';

class Light extends Object3D {
  late double intensity;
  Color? color;
  double? distance;
  LightShadow? shadow;
  SphericalHarmonics3? sh;

  double? angle;
  double? decay;

  Object3D? target;
  double? penumbra;

  num? width;
  num? height;

  bool isRectAreaLight = false;
  bool isHemisphereLightProbe = false;
  bool isHemisphereLight = false;

  Color? groundColor;

  Light(int? color, [double? intensity]) : super() {
    if(color != null){
      this.color = Color.fromHex(color);
    }
    this.intensity = intensity ?? 1.0;
    type = "Light";
  }

  Light.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON):super.fromJSON(json, rootJSON) {
    type = "Light";
    if (json["color"] != null) {
      color = Color(0, 0, 0).setHex(json["color"]);
    }
    intensity = json["intensity"] ?? 1;
  }

  @override
  Light copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    Light source1 = source as Light;

    color!.copy(source1.color!);
    intensity = source1.intensity;

    return this;
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    Map<String, dynamic> data = super.toJSON(meta: meta);

    data["object"]["color"] = color!.getHex();
    data["object"]["intensity"] = intensity;

    if (groundColor != null) {
      data["object"]["groundColor"] = groundColor!.getHex();
    }

    if (distance != null) {
      data["object"]["distance"] = distance;
    }
    if (angle != null) {
      data["object"]["angle"] = angle;
    }
    if (decay != null) {
      data["object"]["decay"] = decay;
    }
    if (penumbra != null) {
      data["object"]["penumbra"] = penumbra;
    }

    if (shadow != null) {
      data["object"]["shadow"] = shadow!.toJSON();
    }

    return data;
  }

  @override
  void dispose() {
    // Empty here in base class; some subclasses override.
  }

  @override
  dynamic getProperty(String propertyName) {
    if (propertyName == "color") {
      return color;
    } else if (propertyName == "intensity") {
      return intensity;
    } else {
      return super.getProperty(propertyName);
    }
  }

  @override
  Light setProperty(String propertyName, dynamic value) {
    if (propertyName == "intensity") {
      intensity = value;
    } else {
      super.setProperty(propertyName, value);
    }

    return this;
  }
}
