import 'package:three_dart/three3d/constants.dart';
import './texture.dart';

class FramebufferTexture extends Texture {
  FramebufferTexture(int width, int height, int format):super(null, null, null, null, null, null, format) {
    this.format = format;
    magFilter = NearestFilter;
    minFilter = NearestFilter;
    generateMipmaps = false;
    needsUpdate = true;
  }
}