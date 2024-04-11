import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light.dart';

class LightProbe extends Light {
  LightProbe.create([SphericalHarmonics3? sh, double? intensity]) : super(null, intensity){
    type = 'LightProbe';
  }
  
  factory LightProbe([SphericalHarmonics3? sh, double? intensity]){
    sh ??= SphericalHarmonics3();
    return LightProbe.create(sh, intensity);
  }
  factory LightProbe.fromJSON(json){
    SphericalHarmonics3 sh3 = SphericalHarmonics3();
    sh3.fromArray(json['sh']);
    return LightProbe.create(sh3, json['intensity']);
  }

  @override
  LightProbe copy(Object3D source, [bool? recursive]) {
    super.copy(source);
    LightProbe source1 = source as LightProbe;
    sh!.copy(source1.sh!);
    return this;
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    Map<String, dynamic> data = super.toJSON(meta: meta);
    data["object"]['sh'] = sh!.toArray([]);
    return data;
  }
}
