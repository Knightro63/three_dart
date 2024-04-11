import './texture.dart';

class CanvasTexture extends Texture {
  bool isCanvasTexture = true;

  CanvasTexture(
    canvas, 
    int? mapping, 
    int? wrapS, 
    int? wrapT, 
    int? magFilter, 
    int? minFilter, 
    int? format,
    int? type, 
    int? anisotropy
  ):super(canvas, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy) {
    needsUpdate = true;
  }
}
