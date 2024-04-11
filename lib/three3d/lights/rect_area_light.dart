import 'package:three_dart/three3d/core/index.dart';
import 'light.dart';

class RectAreaLight extends Light {
  RectAreaLight([int? color, double? intensity, num? width, num? height]) : super(color, intensity) {
    type = 'RectAreaLight';

    this.width = width ?? 10;
    this.height = height ?? 10;
    isRectAreaLight = true;
  }

  @override
  RectAreaLight copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    RectAreaLight source1 = source as RectAreaLight;

    width = source1.width;
    height = source1.height;

    return this;
  }

  @override
  Map<String,dynamic> toJSON({Object3dMeta? meta}) {
    Map<String,dynamic> data = super.toJSON(meta: meta);

    data["object"]["width"] = width;
    data["object"]["height"] = height;

    return data;
  }
}
