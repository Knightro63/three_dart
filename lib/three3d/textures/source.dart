import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'image_element.dart';

class Source {
  late String uuid;
  dynamic data;
  late int version;

  int currentVersion = 0;

	Source([this.data]){
    uuid = MathUtils.generateUUID();
    version = 0;
	}

	set needsUpdate( value ) {
    if (value == true) version++;
	}

	Map<String,dynamic> toJSON(meta) {
		final isRootObject = ( meta == null || meta is String );

    if (!isRootObject && meta.images[uuid] != null) {
      return meta.images[uuid];
		}

		final output = {
			"uuid": uuid,
			"url": ''
		};

		final data = this.data;

		if ( data != null ) {
			dynamic url;

			if ( data is List ) {
				url = [];

				for ( int i = 0, l = data.length; i < l; i ++ ) {
					if ( data[ i ].isDataTexture ) {
						url.add( serializeImage( data[ i ].image ) );
					} 
          else {
						url.add( serializeImage( data[ i ] ) );
					}
				}
			} 
      else {
				url = serializeImage( data );
			}

			output["url"] = url;
		}

		if(!isRootObject){
      meta.images[uuid] = output;
		}

		return output;
	}
}

Map<String,dynamic> serializeImage( image ) {
	if (image is ImageElement){
		return ImageUtils.getDataURL( image );
	} 
  else {
		if ( image.data != null ) {
			return {
				"data": image.data.sublist(0),
				"width": image.width,
				"height": image.height,
				"type": image.data.runtimeType.toString()
			};

		} 
    else {
			print( 'THREE.Texture: Unable to serialize Texture.' );
			return {};
		}
	}
}
