import 'package:flutter_gl/flutter_gl.dart';
import 'buffer_attribute.dart';

enum AttributeTypes{position,normal,color,uv,uv2,tangent,lineDistances,skinWeights,skinIndex,faceIndex}

class Attributes{
  Attributes({
    this.position,
    this.normal,
    this.color,
    this.uv2,
    this.uv,
    this.tangent,
    this.lineDistances
  });
  BufferAttribute<NativeArray<num>>? faceIndexBuffer;
  BufferAttribute<NativeArray<num>>? skinIndexBuffer;
  BufferAttribute<NativeArray<num>>? skinWeightsBuffer;
  BufferAttribute<NativeArray<num>>? position;
  BufferAttribute<NativeArray<num>>? normal;
  BufferAttribute<NativeArray<num>>? color;
  BufferAttribute<NativeArray<num>>? uv;
  BufferAttribute<NativeArray<num>>? uv2;
  BufferAttribute<NativeArray<num>>? lineDistances;
  BufferAttribute<NativeArray<num>>? tangent;
  // //List<Color> color
  // List<Color>? get color => color != null?List<Color>.generate(
  //   color!.length,
  //   (i){
  //     return Color(0,0,0).fromBufferAttribute(color!, i);
  //   }
  // ):null;

  // List<Vector3>? get normal => normal != null?List<Vector3>.generate(
  //   normal!.length,
  //   (i){
  //     return Vector3().fromBufferAttribute(normal!, i);
  //   }
  // ):null;
  // List<Vector4>? get skinWeights => skinWeightsBuffer != null?List<Vector4>.generate(
  //   skinWeightsBuffer!.length,
  //   (i){
  //     return Vector4().fromBufferAttribute(skinWeightsBuffer!, i);
  //   }
  // ):null;
  // List<Vector3>? get position => position != null?List<Vector3>.generate(
  //   position!.length,
  //   (i){
  //     return Vector3().fromBufferAttribute(position!, i);
  //   }
  // ):null;

  // List<Vector2>? get uv => uv != null?List<Vector2>.generate(
  //   uv!.length,
  //   (i){
  //     return Vector2().fromBufferAttribute(uv!, i);
  //   }
  // ):null;

  // List<Vector2>? get uv2 => uv2 != null?List<Vector2>.generate(
  //   uv2!.length,
  //   (i){
  //     return Vector2().fromBufferAttribute(uv2!, i);
  //   }
  // ):null;

  // Float32Array? get lineDistances => lineDistances != null?Float32Array.from(List<double>.from(lineDistances!.array.toDartList())):null;

  // List<Vector3>? get tangent => tangent != null?List<Vector3>.generate(
  //   tangent!.length,
  //   (i){
  //     return Vector3().fromBufferAttribute(tangent!, i);
  //   }
  // ):null;

  List<AttributeTypes> get keys => AttributeTypes.values.toList();
  void operator []=(AttributeTypes key, BufferAttribute<NativeArray<num>>? value) => setAttribute(key, value);
  BufferAttribute<NativeArray<num>>? operator [](AttributeTypes? key) => getAttribute(key);

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
      normal:normal,
      tangent: tangent,
      color: color,
      position: position,
      uv2: uv2,
      uv: uv,
      lineDistances: lineDistances
    );
  }
  BufferAttribute<NativeArray<num>>? getAttribute(AttributeTypes? type){
    switch (type) {
      case AttributeTypes.color:
        return color;
      case AttributeTypes.position:
        return position;
      case AttributeTypes.normal:
        return normal;
      case AttributeTypes.uv:
        return uv;
      case AttributeTypes.uv2:
        return uv2;
      case AttributeTypes.tangent:
        return tangent;
      case AttributeTypes.lineDistances:
        return lineDistances;
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
        color = value;
        break;
      case AttributeTypes.position:
        position = value;
        break;
      case AttributeTypes.normal:
        normal = value;
        break;
      case AttributeTypes.uv:
        uv = value;
        break;
      case AttributeTypes.uv2:
        uv2 = value;
        break;
      case AttributeTypes.lineDistances:
        lineDistances = value;
        break;
      case AttributeTypes.tangent:
        tangent = value;
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
        return color != null;
      case AttributeTypes.position:
        return position != null;
      case AttributeTypes.normal:
        return normal != null;
      case AttributeTypes.uv:
        return uv != null;
      case AttributeTypes.uv2:
        return uv2 != null;
      case AttributeTypes.tangent:
        return tangent != null;
      case AttributeTypes.lineDistances:
        return lineDistances != null;
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