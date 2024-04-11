import 'light.dart';

class AmbientLight extends Light {
  bool isAmbientLight = true;

  AmbientLight(int? color, [double? intensity]):super(color, intensity) {
    type = 'AmbientLight';
  }

  AmbientLight.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON): super.fromJSON(json, rootJSON) {
    type = 'AmbientLight';
  }
}
