import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart';

enum AttributeTypes{position,normal,color,uv,uv2,tangent,lineDistances,skinWeights,skinIndex,faceIndex}

class Attributes{
  Attributes({
    this.positionBuffer,
    this.normalBuffer,
    this.colorBuffer,
    this.uv2Buffer,
    this.uvBuffer,
    this.tangentBuffer,
    this.lineDistancesBuffer
  });
  BufferAttribute<NativeArray<num>>? faceIndexBuffer;
  BufferAttribute<NativeArray<num>>? skinIndexBuffer;
  BufferAttribute<NativeArray<num>>? skinWeightsBuffer;
  BufferAttribute<NativeArray<num>>? positionBuffer;
  BufferAttribute<NativeArray<num>>? normalBuffer;
  BufferAttribute<NativeArray<num>>? colorBuffer;
  BufferAttribute<NativeArray<num>>? uvBuffer;
  BufferAttribute<NativeArray<num>>? uv2Buffer;
  BufferAttribute<NativeArray<num>>? lineDistancesBuffer;
  BufferAttribute<NativeArray<num>>? tangentBuffer;
  //List<Color> color
  List<Color>? get color => colorBuffer != null?List<Color>.generate(
    colorBuffer!.length,
    (i){
      return Color(0,0,0).fromBufferAttribute(colorBuffer!, i);
    }
  ):null;

  List<Vector3>? get normal => normalBuffer != null?List<Vector3>.generate(
    normalBuffer!.length,
    (i){
      return Vector3().fromBufferAttribute(normalBuffer!, i);
    }
  ):null;
  List<Vector4>? get skinWeights => skinWeightsBuffer != null?List<Vector4>.generate(
    skinWeightsBuffer!.length,
    (i){
      return Vector4().fromBufferAttribute(skinWeightsBuffer!, i);
    }
  ):null;
  List<Vector3>? get position => positionBuffer != null?List<Vector3>.generate(
    positionBuffer!.length,
    (i){
      return Vector3().fromBufferAttribute(positionBuffer!, i);
    }
  ):null;

  List<Vector2>? get uv => uvBuffer != null?List<Vector2>.generate(
    uvBuffer!.length,
    (i){
      return Vector2().fromBufferAttribute(uvBuffer!, i);
    }
  ):null;

  List<Vector2>? get uv2 => uv2Buffer != null?List<Vector2>.generate(
    uv2Buffer!.length,
    (i){
      return Vector2().fromBufferAttribute(uv2Buffer!, i);
    }
  ):null;

  Float32Array? get lineDistances => lineDistancesBuffer != null?Float32Array.from(List<double>.from(lineDistancesBuffer!.array.toDartList())):null;

  List<Vector3>? get tangent => tangentBuffer != null?List<Vector3>.generate(
    tangentBuffer!.length,
    (i){
      return Vector3().fromBufferAttribute(tangentBuffer!, i);
    }
  ):null;

  List<AttributeTypes> get keys => AttributeTypes.values.toList();

  BufferAttribute<NativeArray<num>>? getAttributefromString(String name){
    for(int i = 0; i < AttributeTypes.values.length;i++){
      if(AttributeTypes.values[i].name == name){
        return getAttribute(AttributeTypes.values[i]);
      }
    }

    return null;
  }
  AttributeTypes? getAttributeTypefromString(String name){
    for(int i = 0; i < AttributeTypes.values.length;i++){
      if(AttributeTypes.values[i].name == name){
        return AttributeTypes.values[i];
      }
    }

    return null;
  }
  Attributes clone(){
    return Attributes(
      normalBuffer:normalBuffer,
      tangentBuffer: tangentBuffer,
      colorBuffer: colorBuffer,
      positionBuffer: positionBuffer,
      uv2Buffer: uv2Buffer,
      uvBuffer: uvBuffer,
      lineDistancesBuffer: lineDistancesBuffer
    );
  }
  BufferAttribute<NativeArray<num>>? getAttribute(AttributeTypes type){
    switch (type) {
      case AttributeTypes.color:
        return colorBuffer;
      case AttributeTypes.position:
        return positionBuffer;
      case AttributeTypes.normal:
        return normalBuffer;
      case AttributeTypes.uv:
        return uvBuffer;
      case AttributeTypes.uv2:
        return uv2Buffer;
      case AttributeTypes.tangent:
        return tangentBuffer;
      case AttributeTypes.lineDistances:
        return lineDistancesBuffer;
      case AttributeTypes.skinWeights:
        return skinWeightsBuffer;
      case AttributeTypes.skinIndex:
        return skinIndexBuffer;
      case AttributeTypes.faceIndex:
        return faceIndexBuffer;
      default:
        return null;
    }
  }
  void setAttribute(AttributeTypes type, [BufferAttribute<NativeArray<num>>? value]){
    switch (type) {
      case AttributeTypes.color:
        colorBuffer = value;
        break;
      case AttributeTypes.position:
        positionBuffer = value;
        break;
      case AttributeTypes.normal:
        normalBuffer = value;
        break;
      case AttributeTypes.uv:
        uvBuffer = value;
        break;
      case AttributeTypes.uv2:
        uv2Buffer = value;
        break;
      case AttributeTypes.lineDistances:
        lineDistancesBuffer = value;
        break;
      case AttributeTypes.tangent:
        tangentBuffer = value;
        break;
      case AttributeTypes.skinWeights:
        skinWeightsBuffer = value;
        break;
      case AttributeTypes.skinIndex:
        skinIndexBuffer = value;
        break;
      case AttributeTypes.faceIndex:
        faceIndexBuffer = value;
        break;
    }
  }
  bool hasAttribute(AttributeTypes type){
    switch (type) {
      case AttributeTypes.color:
        return colorBuffer != null;
      case AttributeTypes.position:
        return positionBuffer != null;
      case AttributeTypes.normal:
        return normalBuffer != null;
      case AttributeTypes.uv:
        return uvBuffer != null;
      case AttributeTypes.uv2:
        return uv2Buffer != null;
      case AttributeTypes.tangent:
        return tangentBuffer != null;
      case AttributeTypes.lineDistances:
        return lineDistancesBuffer != null;
      case AttributeTypes.skinWeights:
        return skinWeightsBuffer != null;
      case AttributeTypes.skinIndex:
        return skinIndexBuffer != null;
      case AttributeTypes.faceIndex:
        return faceIndexBuffer != null;
      default:
        return false;
    }
  }
}