import 'package:three_dart/three3d/math/index.dart';
import './fog.dart';

class FogExp2 extends FogBase {
  FogExp2(color, density) {
    name = '';

    if (color is int) {
      this.color = Color(0, 0, 0).setHex(color);
    } else if (color is Color) {
      this.color = color;
    } else {
      throw (" Fog color type: ${color.runtimeType} is not support ... ");
    }

    this.density = (density != null) ? density : 0.00025;
    isFogExp2 = true;
  }

  FogExp2 clone() {
    return FogExp2(color, density);
  }

  @override
  Map<String,dynamic> toJSON(/* meta */) {
    return {
      "type": 'FogExp2',
      "color": color.getHex(),
      "density": density
    };
  }
}
