import 'dart:convert';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/three3d/utils.dart';

import '../math/index.dart';
import '../geometries/index.dart';
import '../extras/index.dart';
import 'buffer_attribute.dart';
import 'event_dispatcher.dart';
import 'gl_buffer_attribute.dart';
import 'interleaved_buffer_attribute.dart';
import 'object_3d.dart';
import './morph_target.dart';

int _bufferGeometryId = 1; // BufferGeometry uses odd numbers as Id

final _bufferGeometrym1 = Matrix4();
final _bufferGeometryobj = Object3D();
final _bufferGeometryoffset = Vector3();
final _bufferGeometrybox = Box3(null, null);
final _bufferGeometryboxMorphTargets = Box3(null, null);
final _bufferGeometryvector = Vector3();

class BufferGeometry with EventDispatcher {
  int id = _bufferGeometryId += 2;
  String uuid = MathUtils.generateUUID();

  String type = "BufferGeometry";
  Box3? boundingBox;
  String name = "";
  Map<String, dynamic> attributes = {};
  Map<String, List<BufferAttribute>> morphAttributes = {};
  bool morphTargetsRelative = false;
  Sphere? boundingSphere;
  Map<String, int> drawRange = {"start": 0, "count": double.maxFinite.toInt()};
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> groups = [];
  BufferAttribute? index;

  late List<MorphTarget> morphTargets;
  late BufferGeometry directGeometry;

  bool elementsNeedUpdate = false;
  bool verticesNeedUpdate = false;
  bool uvsNeedUpdate = false;
  bool normalsNeedUpdate = false;
  bool colorsNeedUpdate = false;
  bool lineDistancesNeedUpdate = false;
  bool groupsNeedUpdate = false;

  late List<Color> colors;
  late List<num> lineDistances;

  Map<String, dynamic>? parameters;

  late num curveSegments;
  late List<Shape> shapes;

  int? maxInstanceCount;
  int? instanceCount;

  BufferGeometry();

  BufferGeometry.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    uuid = json["uuid"];
    type = json["type"];
  }

  static BufferGeometry castJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    String type = json["type"];

    if (type == "BufferGeometry") {
      return BufferGeometry.fromJSON(json, rootJSON);
    } else if (type == "ShapeBufferGeometry") {
      return ShapeGeometry.fromJSON(json, rootJSON);
    } else if (type == "ExtrudeBufferGeometry") {
      return ExtrudeGeometry.fromJSON(json, rootJSON);
    } else {
      throw (" BufferGeometry castJSON _type: $type is not support yet ");
    }
  }

  BufferAttribute? getIndex() => index;

  void setIndex(index) {
    if (index is List) {
      final list = index.map<int>((e) => e.toInt()).toList();
      final max = arrayMax(list);
      if (max != null && max > 65535) {
        this.index = Uint32BufferAttribute(Uint32Array.from(list), 1, false);
      } 
      else {
        this.index = Uint16BufferAttribute(Uint16Array.from(list), 1, false);
      }
    } 
    else {
      this.index = index;
    }
  }

  dynamic getAttribute(String name) {
    return attributes[name];
  }

  BufferGeometry setAttribute(String name, attribute) {
    attributes[name] = attribute;
    return this;
  }

  BufferGeometry deleteAttribute(String name) {
    attributes.remove(name);
    return this;
  }

  bool hasAttribute(String name) {
    return attributes[name] != null;
  }

  void addGroup(int start, int count, [int materialIndex = 0]) {
    groups.add({
      "start": start,
      "count": count,
      "materialIndex": materialIndex,
    });
  }

  void clearGroups() {
    groups = [];
  }

  void setDrawRange(int start, int count) {
    drawRange["start"] = start;
    drawRange["count"] = count;
  }

  void applyMatrix4(Matrix4 matrix) {
    final position = attributes["position"];
    if (position != null) {
      position.applyMatrix4(matrix);
      position.needsUpdate = true;
    }

    final normal = attributes["normal"];

    if (normal != null) {
      final normalMatrix = Matrix3().getNormalMatrix(matrix);

      normal.applyNormalMatrix(normalMatrix);

      normal.needsUpdate = true;
    }

    final tangent = attributes["tangent"];

    if (tangent != null) {
      tangent.transformDirection(matrix);

      tangent.needsUpdate = true;
    }

    if (boundingBox != null) {
      computeBoundingBox();
    }

    if (boundingSphere != null) {
      computeBoundingSphere();
    }
  }

  BufferGeometry applyQuaternion(Quaternion q) {
    m1.makeRotationFromQuaternion(q);
    applyMatrix4(m1);
    return this;
  }

  BufferGeometry rotateX(num angle) {
    // rotate geometry around world x-axis
    _bufferGeometrym1.makeRotationX(angle);
    applyMatrix4(_bufferGeometrym1);
    return this;
  }

  BufferGeometry rotateY(num angle) {
    // rotate geometry around world y-axis
    _bufferGeometrym1.makeRotationY(angle);
    applyMatrix4(_bufferGeometrym1);
    return this;
  }

  BufferGeometry rotateZ(num angle) {
    // rotate geometry around world z-axis
    _bufferGeometrym1.makeRotationZ(angle);
    applyMatrix4(_bufferGeometrym1);
    return this;
  }

  BufferGeometry translate(num x, num y, num z) {
    // translate geometry
    _bufferGeometrym1.makeTranslation(x, y, z);
    applyMatrix4(_bufferGeometrym1);
    return this;
  }

  BufferGeometry translateWithVector3(Vector3 v3) {
    return translate(v3.x, v3.y, v3.z);
  }

  BufferGeometry scale(num x, num y, num z) {
    // scale geometry
    _bufferGeometrym1.makeScale(x, y, z);
    applyMatrix4(_bufferGeometrym1);
    return this;
  }

  BufferGeometry lookAt(Vector3 vector) {
    _bufferGeometryobj.lookAt(vector);
    _bufferGeometryobj.updateMatrix();
    applyMatrix4(_bufferGeometryobj.matrix);
    return this;
  }

  void center() {
    computeBoundingBox();

    boundingBox!.getCenter(_bufferGeometryoffset);
    _bufferGeometryoffset.negate();

    translate(_bufferGeometryoffset.x, _bufferGeometryoffset.y,
        _bufferGeometryoffset.z);
  }

  BufferGeometry setFromPoints(points) {
    List<double> position = [];

    for (int i = 0, l = points.length; i < l; i++) {
      final point = points[i];

      if (point is Vector2) {
        position.addAll([point.x.toDouble(), point.y.toDouble(), 0.0]);
      } 
      else {
        position.addAll([point.x.toDouble(), point.y.toDouble(), (point.z ?? 0).toDouble()]);
      }
    }

    final array = Float32Array.from(position);
    setAttribute('position', Float32BufferAttribute(array, 3, false));

    return this;
  }

  void computeBoundingBox() {
    boundingBox ??= Box3(null, null);

    final position = attributes["position"];
    final morphAttributesPosition = morphAttributes["position"];

    if (position != null && position is GLBufferAttribute) {
      print(
          'THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false". $this');

      double infinity = 9999999999.0;

      boundingBox!.set(Vector3(-infinity, -infinity, -infinity),
          Vector3(infinity, infinity, infinity));

      return;
    }

    if (position != null) {
      boundingBox!.setFromBufferAttribute(position);

      // process morph attributes if present

      if (morphAttributesPosition != null) {
        for (int i = 0, il = morphAttributesPosition.length; i < il; i++) {
          final morphAttribute = morphAttributesPosition[i];
          _bufferGeometrybox.setFromBufferAttribute(morphAttribute);

          if (morphTargetsRelative) {
            _bufferGeometryvector.addVectors(
                boundingBox!.min, _bufferGeometrybox.min);
            boundingBox!.expandByPoint(_bufferGeometryvector);

            _bufferGeometryvector.addVectors(
                boundingBox!.max, _bufferGeometrybox.max);
            boundingBox!.expandByPoint(_bufferGeometryvector);
          } else {
            boundingBox!.expandByPoint(_bufferGeometrybox.min);
            boundingBox!.expandByPoint(_bufferGeometrybox.max);
          }
        }
      }
    } else {
      boundingBox!.makeEmpty();
    }

    // if (boundingBox!.min.x == null ||
    //     boundingBox!.min.y == null ||
    //     boundingBox!.min.z == null) {
    //   print(
    //       'THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values. ${this}');
    // }
  }

  void computeBoundingSphere() {
    boundingSphere ??= Sphere(null, null);

    final position = attributes["position"];
    final morphAttributesPosition = morphAttributes["position"];

    if (position != null && position is GLBufferAttribute) {
      boundingSphere!.set(Vector3(), 99999999999);

      return;
    }

    if (position != null) {
      // first, find the center of the bounding sphere

      final center = boundingSphere!.center;

      _bufferGeometrybox.setFromBufferAttribute(position);

      // process morph attributes if present

      if (morphAttributesPosition != null) {
        for (int i = 0, il = morphAttributesPosition.length; i < il; i++) {
          final morphAttribute = morphAttributesPosition[i];
          _bufferGeometryboxMorphTargets.setFromBufferAttribute(morphAttribute);

          if (morphTargetsRelative) {
            _bufferGeometryvector.addVectors(
                _bufferGeometrybox.min, _bufferGeometryboxMorphTargets.min);
            _bufferGeometrybox.expandByPoint(_bufferGeometryvector);

            _bufferGeometryvector.addVectors(
                _bufferGeometrybox.max, _bufferGeometryboxMorphTargets.max);
            _bufferGeometrybox.expandByPoint(_bufferGeometryvector);
          } else {
            _bufferGeometrybox
                .expandByPoint(_bufferGeometryboxMorphTargets.min);
            _bufferGeometrybox
                .expandByPoint(_bufferGeometryboxMorphTargets.max);
          }
        }
      }

      _bufferGeometrybox.getCenter(center);

      // second, try to find a boundingSphere with a radius smaller than the
      // boundingSphere of the boundingBox: sqrt(3) smaller in the best case
      num maxRadiusSq = 0;
      for (int i = 0, il = position.count; i < il; i++) {
        _bufferGeometryvector.fromBufferAttribute(position, i);
        maxRadiusSq = Math.max(
          maxRadiusSq,
          center.distanceToSquared(_bufferGeometryvector),
        );
      }

      // process morph attributes if present

      if (morphAttributesPosition != null) {
        for (int i = 0, il = morphAttributesPosition.length; i < il; i++) {
          final morphAttribute = morphAttributesPosition[i];
          final morphTargetsRelative = this.morphTargetsRelative;

          for (int j = 0, jl = morphAttribute.count; j < jl; j++) {
            _bufferGeometryvector.fromBufferAttribute(morphAttribute, j);

            if (morphTargetsRelative) {
              _bufferGeometryoffset.fromBufferAttribute(position, j);
              _bufferGeometryvector.add(_bufferGeometryoffset);
            }

            maxRadiusSq = Math.max(
              maxRadiusSq,
              center.distanceToSquared(_bufferGeometryvector),
            );
          }
        }
      }

      boundingSphere!.radius = Math.sqrt(maxRadiusSq);

      if (boundingSphere?.radius == null) {
        print(
            'THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values. $this');
      }
    }
  }

  void computeFaceNormals() {
    // backwards compatibility
  }

  void computeTangents() {
    final index = this.index;
    final attributes = this.attributes;

    // based on http://www.terathon.com/code/tangent.html
    // (per vertex tangents)

    if (index == null ||
        attributes["position"] == null ||
        attributes["normal"] == null ||
        attributes["uv"] == null) {
      Console.error(
          'THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)');
      return;
    }

    final indices = index.array;
    final positions = attributes["position"].array;
    final normals = attributes["normal"].array;
    final uvs = attributes["uv"].array;

    int nVertices = positions.length ~/ 3;

    if (attributes["tangent"] == null) {
      setAttribute(
          'tangent', Float32BufferAttribute(Float32Array(4 * nVertices), 4));
    }

    final tangents = attributes["tangent"].array;

    final List<Vector3> tan1 = [], tan2 = [];

    for (int i = 0; i < nVertices; i++) {
      tan1.add(Vector3());
      tan2.add(Vector3());
    }

    final vA = Vector3(),
        vB = Vector3(),
        vC = Vector3(),
        uvA = Vector2(),
        uvB = Vector2(),
        uvC = Vector2(),
        sdir = Vector3(),
        tdir = Vector3();

    void handleTriangle(int a, int b, int c) {
      vA.fromArray(positions, a * 3);
      vB.fromArray(positions, b * 3);
      vC.fromArray(positions, c * 3);

      uvA.fromArray(uvs, a * 2);
      uvB.fromArray(uvs, b * 2);
      uvC.fromArray(uvs, c * 2);

      vB.sub(vA);
      vC.sub(vA);

      uvB.sub(uvA);
      uvC.sub(uvA);

      num r = 1.0 / (uvB.x * uvC.y - uvC.x * uvB.y);

      // silently ignore degenerate uv triangles having coincident or colinear vertices

      if (!r.isFinite) return;

      sdir
          .copy(vB)
          .multiplyScalar(uvC.y)
          .addScaledVector(vC, -uvB.y)
          .multiplyScalar(r);
      tdir
          .copy(vC)
          .multiplyScalar(uvB.x)
          .addScaledVector(vB, -uvC.x)
          .multiplyScalar(r);

      tan1[a].add(sdir);
      tan1[b].add(sdir);
      tan1[c].add(sdir);

      tan2[a].add(tdir);
      tan2[b].add(tdir);
      tan2[c].add(tdir);
    }

    List<Map<String,dynamic>> groups = this.groups;

    if (groups.isEmpty) {
      groups = [
        {"start": 0, "count": indices.length}
      ];
    }

    for (int i = 0, il = groups.length; i < il; ++i) {
      final group = groups[i];

      final start = group["start"];
      final count = group["count"];

      for (int j = start, jl = start + count; j < jl; j += 3) {
        handleTriangle(
          indices[j + 0].toInt(),
          indices[j + 1].toInt(),
          indices[j + 2].toInt(),
        );
      }
    }

    final tmp = Vector3(), tmp2 = Vector3();
    final n = Vector3(), n2 = Vector3();

    void handleVertex(int v) {
      n.fromArray(normals, v * 3);
      n2.copy(n);

      final t = tan1[v];

      // Gram-Schmidt orthogonalize

      tmp.copy(t);
      tmp.sub(n.multiplyScalar(n.dot(t))).normalize();

      // Calculate handedness

      tmp2.crossVectors(n2, t);
      final test = tmp2.dot(tan2[v]);
      final w = (test < 0.0) ? -1.0 : 1.0;

      tangents[v * 4] = tmp.x;
      tangents[v * 4 + 1] = tmp.y;
      tangents[v * 4 + 2] = tmp.z;
      tangents[v * 4 + 3] = w;
    }

    for (int i = 0, il = groups.length; i < il; ++i) {
      final group = groups[i];

      final start = group["start"];
      final count = group["count"];

      for (int j = start, jl = start + count; j < jl; j += 3) {
        handleVertex(indices[j + 0].toInt());
        handleVertex(indices[j + 1].toInt());
        handleVertex(indices[j + 2].toInt());
      }
    }
  }

  void computeVertexNormals() {
    final index = this.index;
    final positionAttribute = getAttribute('position');

    if (positionAttribute != null) {
      Float32BufferAttribute? normalAttribute = getAttribute('normal');

      if (normalAttribute == null) {
        final array = List<double>.filled(positionAttribute.count * 3, 0);
        normalAttribute = Float32BufferAttribute(Float32Array.from(array), 3, false);
        setAttribute('normal', normalAttribute);
      } 
      else {
        // reset existing normals to zero
        for (int i = 0, il = normalAttribute.count; i < il; i++) {
          normalAttribute.setXYZ(i, 0, 0, 0);
        }
      }

      final pA = Vector3(), pB = Vector3(), pC = Vector3();
      final nA = Vector3(), nB = Vector3(), nC = Vector3();
      final cb = Vector3(), ab = Vector3();

      // indexed elements

      if (index != null) {
        for (int i = 0, il = index.count; i < il; i += 3) {
          final vA = index.getX(i + 0)!.toInt();
          final vB = index.getX(i + 1)!.toInt();
          final vC = index.getX(i + 2)!.toInt();

          pA.fromBufferAttribute(positionAttribute, vA);
          pB.fromBufferAttribute(positionAttribute, vB);
          pC.fromBufferAttribute(positionAttribute, vC);

          cb.subVectors(pC, pB);
          ab.subVectors(pA, pB);
          cb.cross(ab);

          nA.fromBufferAttribute(normalAttribute, vA);
          nB.fromBufferAttribute(normalAttribute, vB);
          nC.fromBufferAttribute(normalAttribute, vC);

          nA.add(cb);
          nB.add(cb);
          nC.add(cb);

          normalAttribute.setXYZ(vA, nA.x, nA.y, nA.z);
          normalAttribute.setXYZ(vB, nB.x, nB.y, nB.z);
          normalAttribute.setXYZ(vC, nC.x, nC.y, nC.z);
        }
      } else {
        // non-indexed elements (unconnected triangle soup)

        for (int i = 0, il = positionAttribute.count; i < il; i += 3) {
          pA.fromBufferAttribute(positionAttribute, i + 0);
          pB.fromBufferAttribute(positionAttribute, i + 1);
          pC.fromBufferAttribute(positionAttribute, i + 2);

          cb.subVectors(pC, pB);
          ab.subVectors(pA, pB);
          cb.cross(ab);

          normalAttribute.setXYZ(i + 0, cb.x, cb.y, cb.z);
          normalAttribute.setXYZ(i + 1, cb.x, cb.y, cb.z);
          normalAttribute.setXYZ(i + 2, cb.x, cb.y, cb.z);
        }
      }

      normalizeNormals();

      normalAttribute.needsUpdate = true;
    }
  }

  BufferGeometry merge(BufferGeometry geometry, [int? offset]) {
    // if (!(geometry && geometry.isBufferGeometry)) {
    //   print(
    //       'THREE.BufferGeometry.merge(): geometry not an instance of THREE.BufferGeometry. $geometry');
    //   return;
    // }

    if (offset == null) {
      offset = 0;

      print(
          'THREE.BufferGeometry.merge(): Overwriting original geometry, starting at offset=0. '
          'Use BufferGeometryUtils.mergeBufferGeometries() for lossless merge.');
    }

    final attributes = this.attributes;

    for (String key in attributes.keys) {
      if (geometry.attributes[key] != null) {
        final attribute1 = attributes[key];
        final attributeArray1 = attribute1.array;

        final attribute2 = geometry.attributes[key];
        final attributeArray2 = attribute2.array;

        final attributeOffset = attribute2.itemSize * offset;
        final length = Math.min<int>(
            attributeArray2.length, attributeArray1.length - attributeOffset);

        for (int i = 0, j = attributeOffset; i < length; i++, j++) {
          attributeArray1[j] = attributeArray2[i];
        }
      }
    }

    return this;
  }

  void normalizeNormals() {
    final normals = attributes["normal"];

    for (int i = 0, il = normals.count; i < il; i++) {
      _bufferGeometryvector.fromBufferAttribute(normals, i);

      _bufferGeometryvector.normalize();

      normals.setXYZ(i, _bufferGeometryvector.x, _bufferGeometryvector.y,
          _bufferGeometryvector.z);
    }
  }

  BufferGeometry toNonIndexed() {
    convertBufferAttribute(attribute, indices) {
      print("BufferGeometry.convertBufferAttribute todo  ");

      final array = attribute.array;
      final itemSize = attribute.itemSize;
      final normalized = attribute.normalized;

      final array2 = Float32Array(indices.length * itemSize);

      int index = 0, index2 = 0;

      for (int i = 0, l = indices.length; i < l; i++) {
        if (attribute is InterleavedBufferAttribute) {
          index = indices[i] * attribute.data!.stride + attribute.offset;
        } else {
          index = indices[i] * itemSize;
        }

        for (int j = 0; j < itemSize; j++) {
          array2[index2++] = array[index++];
        }
      }

      return Float32BufferAttribute(array2, itemSize, normalized);
    }

    //

    if (index == null) {
      print(
          'THREE.BufferGeometry.toNonIndexed(): Geometry is already non-indexed.');
      return this;
    }

    final geometry2 = BufferGeometry();

    final indices = index!.array;
    final attributes = this.attributes;

    // attributes

    for (String name in attributes.keys) {
      final attribute = attributes[name];

      final newAttribute = convertBufferAttribute(attribute, indices);

      geometry2.setAttribute(name, newAttribute);
    }

    // morph attributes

    final morphAttributes = this.morphAttributes;

    for (String name in morphAttributes.keys) {
      List<BufferAttribute> morphArray = [];
      List<BufferAttribute> morphAttribute = morphAttributes[
          name]!; // morphAttribute: array of Float32BufferAttributes

      for (int i = 0, il = morphAttribute.length; i < il; i++) {
        final attribute = morphAttribute[i];

        final newAttribute = convertBufferAttribute(attribute, indices);

        morphArray.add(newAttribute);
      }

      geometry2.morphAttributes[name] = morphArray;
    }

    geometry2.morphTargetsRelative = morphTargetsRelative;

    // groups

    List<Map<String,dynamic>> groups = this.groups;

    for (int i = 0, l = groups.length; i < l; i++) {
      final group = groups[i];
      geometry2.addGroup(
          group["start"], group["count"], group["materialIndex"]);
    }

    return geometry2;
  }

  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    Map<String, dynamic> data = {
      "metadata": {
        "version": 4.5,
        "type": 'BufferGeometry',
        "generator": 'BufferGeometry.toJSON'
      }
    };

    // standard BufferGeometry serialization

    data["uuid"] = uuid;
    data["type"] = type;
    if (name != '') data["name"] = name;
    if (userData.keys.isNotEmpty) data["userData"] = userData;

    if (parameters != null) {
      for (String key in parameters!.keys) {
        if (parameters![key] != null) data[key] = parameters![key];
      }

      return data;
    }

    // for simplicity the code assumes attributes are not shared across geometries, see #15811

    data["data"] = {};
    data["data"]["attributes"] = {};

    final index = this.index;

    if (index != null) {
      // TODO
      data["data"]["index"] = {
        "type": index.array.runtimeType.toString(),
        "array": index.array.sublist(0)
      };
    }

    final attributes = this.attributes;

    for (String key in attributes.keys) {
      final attribute = attributes[key];

      // TODO
      // data["data"]["attributes"][ key ] = attribute.toJSON( data["data"] );
      data["data"]["attributes"][key] = attribute.toJSON();
    }

    Map<String, List<BufferAttribute>> morphAttributes = {};
    bool hasMorphAttributes = false;

    for (String key in morphAttributes.keys) {
      final attributeArray = this.morphAttributes[key]!;

      List<BufferAttribute> array = [];

      for (int i = 0, il = attributeArray.length; i < il; i++) {
        final attribute = attributeArray[i];

        // TODO
        // final attributeData = attribute.toJSON( data["data"] );
        // final attributeData = attribute.toJSON();

        array.add(attribute);
      }

      if (array.isNotEmpty) {
        morphAttributes[key] = array;

        hasMorphAttributes = true;
      }
    }

    if (hasMorphAttributes) {
      data["data"].morphAttributes = morphAttributes;
      data["data"].morphTargetsRelative = morphTargetsRelative;
    }

    List<Map<String,dynamic>> groups = this.groups;

    if (groups.isNotEmpty) {
      data["data"]["groups"] = json.decode(json.encode(groups));
    }

    final boundingSphere = this.boundingSphere;

    if (boundingSphere != null) {
      data["data"]["boundingSphere"] = {
        "center": boundingSphere.center.toArray(List.filled(3, 0)),
        "radius": boundingSphere.radius
      };
    }

    return data;
  }

  BufferGeometry clone() {
    return BufferGeometry().copy(this);
  }

  BufferGeometry copy(BufferGeometry source) {
    // reset

    // this.index = null;
    // this.attributes = {};
    // this.morphAttributes = {};
    // this.groups = [];
    // this.boundingBox = null;
    // this.boundingSphere = null;

    // used for storing cloned, shared data

    // Map data = {};

    // name

    name = source.name;

    // index

    final index = source.index;

    if (index != null) {
      setIndex(index.clone());
    }

    // attributes

    final attributes = source.attributes;

    for (String name in attributes.keys) {
      final attribute = attributes[name];
      setAttribute(name, attribute.clone());
    }

    // morph attributes

    final morphAttributes = source.morphAttributes;

    for (String name in morphAttributes.keys) {
      List<BufferAttribute> array = [];
      final morphAttribute = morphAttributes[name]!;
      // morphAttribute: array of Float32BufferAttributes

      for (int i = 0, l = morphAttribute.length; i < l; i++) {
        array.add(morphAttribute[i].clone());
      }

      this.morphAttributes[name] = array;
    }

    morphTargetsRelative = source.morphTargetsRelative;

    // groups

    List<Map<String,dynamic>> groups = source.groups;

    for (int i = 0, l = groups.length; i < l; i++) {
      final group = groups[i];
      addGroup(group["start"], group["count"], group["materialIndex"]);
    }

    // bounding box

    final boundingBox = source.boundingBox;

    if (boundingBox != null) {
      this.boundingBox = boundingBox.clone();
    }

    // bounding sphere

    final boundingSphere = source.boundingSphere;

    if (boundingSphere != null) {
      this.boundingSphere = boundingSphere.clone();
    }

    // draw range

    drawRange["start"] = source.drawRange["start"]!;
    drawRange["count"] = source.drawRange["count"]!;

    // user data

    userData = source.userData;

    return this;
  }

  void dispose() {
    print(" BufferGeometry dispose ........... ");

    dispatchEvent(Event(type: "dispose"));
  }
}

class BufferGeometryParameters {
  late List<Shape> shapes;
  late num curveSegments;
  late Map<String, dynamic> options;
  late num steps;
  late num depth;
  late bool bevelEnabled;
  late num bevelThickness;
  late num bevelSize;
  late num bevelOffset;
  late num bevelSegments;
  late Curve extrudePath;
  late dynamic uvGenerator;
  late num amount;

  BufferGeometryParameters(Map<String, dynamic> json) {
    shapes = json["shapes"];
    curveSegments = json["curveSegments"];
    options = json["options"];
    depth = json["depth"];
  }

  Map<String, dynamic> toJSON() {
    return {"curveSegments": curveSegments};
  }
}
