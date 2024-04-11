import 'math.dart';
import 'color.dart';

enum ColorSpace{linear,srgb}

double srgbToLinear(double c){
	return ( c < 0.04045 ) ? c * 0.0773993808 : Math.pow( c * 0.9478672986 + 0.0521327014, 2.4 ).toDouble();
}

double linearToSRGB(double c) {
	return ( c < 0.0031308 ) ? c * 12.92 : 1.055 * ( Math.pow( c, 0.41666 ) ) - 0.055;
}

// JavaScript RGB-to-RGB transforms, defined as
// FN[InputColorSpace][OutputColorSpace] callback functions.
final fn = {
	ColorSpace.srgb: { 
    ColorSpace.linear: srgbToLinear 
  },
	ColorSpace.linear: { 
    ColorSpace.srgb: linearToSRGB 
  },
};

class ColorManagement {
	static bool legacyMode = true;

	static get workingColorSpace {
		return ColorSpace.linear;
	}

	static set workingColorSpace( colorSpace ) {
		print( 'THREE.ColorManagement: .workingColorSpace is readonly.' );
	}

	static Color convert(Color color, ColorSpace? sourceColorSpace, ColorSpace? targetColorSpace){
		if(
      legacyMode || 
      sourceColorSpace == targetColorSpace || 
      sourceColorSpace == null || 
      targetColorSpace == null
    ) {
			return color;
		}

		if (
      fn[sourceColorSpace] != null && 
      fn[sourceColorSpace]![targetColorSpace] != null
    ){
			final fnC = fn[sourceColorSpace]![targetColorSpace]!;

			color.r = fnC(color.r);
			color.g = fnC(color.g);
			color.b = fnC(color.b);

			return color;
		}

		throw( 'Unsupported color space conversion.' );
	}

	static Color fromWorkingColorSpace(Color color, ColorSpace? targetColorSpace){
		return convert(color, workingColorSpace, targetColorSpace);
	}

	static Color toWorkingColorSpace(Color color, ColorSpace? sourceColorSpace){
		return convert(color, sourceColorSpace, workingColorSpace);
	}
}