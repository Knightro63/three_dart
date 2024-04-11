import './material.dart';
import '../math/index.dart';
import '../constants.dart';

class MeshNormalMaterial extends Material {
  MeshNormalMaterial([Map<String, dynamic>? parameters]) : super() {
    type = "MeshNormalMaterial";
    bumpScale = 1;
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);
    displacementScale = 1;
    displacementBias = 0;
    wireframe = false;
    wireframeLinewidth = 1;
    setValues(parameters);
  }
}
