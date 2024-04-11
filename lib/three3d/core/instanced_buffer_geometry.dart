import '../math/index.dart';
import 'buffer_geometry.dart';
import 'object_3d.dart';

class InstancedBufferGeometry extends BufferGeometry {
  InstancedBufferGeometry() : super() {
    type = 'InstancedBufferGeometry';
    instanceCount = Math.infinity.toInt();
  }

  @override
  InstancedBufferGeometry copy(BufferGeometry source) {
    super.copy(source);
    instanceCount = source.instanceCount;
    return this;
  }

  @override
  BufferGeometry clone() {
    return InstancedBufferGeometry().copy(this);
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    final data = super.toJSON(meta: meta);
    data['instanceCount'] = instanceCount;
    data['isInstancedBufferGeometry'] = true;
    return data;
  }
}
