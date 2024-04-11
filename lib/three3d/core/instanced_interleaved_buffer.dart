import 'package:flutter_gl/flutter_gl.dart';
import 'interleaved_buffer.dart';

class InstancedInterleavedBuffer extends InterleavedBuffer {
  bool isInstancedInterleavedBuffer = true;
  
  InstancedInterleavedBuffer(NativeArray array, stride, meshPerAttribute):super(array, stride) {
    this.meshPerAttribute = meshPerAttribute ?? 1;
    type = "InstancedInterleavedBuffer";
  }

  @override
  InstancedInterleavedBuffer copy(InterleavedBuffer source) {
    super.copy(source);
    if (source is InstancedInterleavedBuffer) {
      meshPerAttribute = source.meshPerAttribute;
    }
    return this;
  }

  @override
  InstancedInterleavedBuffer clone(InterleavedBuffer data) {
    //if(data is InterleavedBuffer) throw('data must be InstancedInterleavedBuffer'); 
    final ib = super.clone(data);
    ib.meshPerAttribute = meshPerAttribute;
    return ib as InstancedInterleavedBuffer;
  }

  @override
  Map<String,dynamic> toJSON(data) {
    final json = super.toJSON(data);

    json["isInstancedInterleavedBuffer"] = true;
    json["meshPerAttributes"] = meshPerAttribute;

    return json;
  }
}
