import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'light_probe.dart';

class AmbientLightProbe extends LightProbe{
  AmbientLightProbe(Color color, [double? intensity]):super.create(null,intensity){
    final color1 = Color(0, 0, 0).setRGB(color.r, color.g, color.b);
    // without extra factor of PI in the shader, would be 2 / Math.sqrt( Math.pi );
    sh!.coefficients[ 0 ].set( color1.r, color1.g, color1.b ).multiplyScalar( 2 * Math.sqrt( Math.pi ) );
  }

  final bool isAmbientLightProbe =  true;

  @override
	Map<String,dynamic> toJSON({Object3dMeta? meta}){
		final data = super.toJSON(meta:meta);
		// data.sh = this.sh.toArray(); // todo
		return data;
	}
}
