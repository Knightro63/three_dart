import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light_probe.dart';

class HemisphereLightProbe extends LightProbe {
  HemisphereLightProbe(Color skyColor, Color groundColor, double? intensity):super.create(null, intensity) {
    final color1 = Color(0, 0, 0).setRGB(skyColor.r, skyColor.g, skyColor.b);
    final color2 = Color(0, 0, 0).setRGB(groundColor.r, groundColor.g, groundColor.b);

    final sky = Vector3(color1.r, color1.g, color1.b);
    final ground = Vector3(color2.r, color2.g, color2.b);

    // without extra factor of PI in the shader, should = 1 / Math.sqrt( Math.pi );
    final c0 = Math.sqrt(Math.pi);
    final c1 = c0 * Math.sqrt(0.75);

    sh!.coefficients[0].copy(sky).add(ground).multiplyScalar(c0);
    sh!.coefficients[1].copy(sky).sub(ground).multiplyScalar(c1);

    isHemisphereLightProbe = false;
  }

  @override
  Map<String,dynamic> toJSON({Object3dMeta? meta}) {
    final data = super.toJSON(meta: meta);
    return data;
  }
}
