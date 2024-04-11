part of three_loaders;

class BufferGeometryLoader extends Loader {
  BufferGeometryLoader([LoadingManager? manager]):super(manager);
  @override
  Future loadAsync(url) async {
    final completer = Completer();
    load(url, (data) {
      completer.complete(data);
    });
    return completer.future;
  }
  @override
  dynamic load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    final scope = this;

    final loader = FileLoader(scope.manager);
    loader.setPath(scope.path);
    loader.setRequestHeader(scope.requestHeader);
    loader.setWithCredentials(scope.withCredentials);
    loader.load(
      url, 
      (text) {
        try {
          onLoad(
            scope._parse(convert.jsonDecode(text))
          );
        } 
        catch (e) {
          if (onError != null) {
            onError(e.toString());
          } 
          else {
            print(e);
          }

          scope.manager.itemError(url);
        }
      }, 
      onProgress, 
      onError
    );
  }

  BufferGeometry _parse(Map<String,dynamic> json) {
    final interleavedBufferMap = {};
    final arrayBufferMap = {};

    getArrayBuffer(json, uuid) {
      if (arrayBufferMap[uuid] != null) return arrayBufferMap[uuid];

      final arrayBuffers = json.arrayBuffers;
      final arrayBuffer = arrayBuffers[uuid];

      final ab = Uint32Array(arrayBuffer).buffer;

      arrayBufferMap[uuid] = ab;

      return ab;
    }

    getInterleavedBuffer(json, uuid) {
      if (interleavedBufferMap[uuid] != null) return interleavedBufferMap[uuid];

      final interleavedBuffers = json.interleavedBuffers;
      final interleavedBuffer = interleavedBuffers[uuid];

      final buffer = getArrayBuffer(json, interleavedBuffer.buffer);

      final array = getTypedArray(interleavedBuffer.type, buffer);
      final ib = InterleavedBuffer(array, interleavedBuffer.stride);
      ib.uuid = interleavedBuffer.uuid;

      interleavedBufferMap[uuid] = ib;

      return ib;
    }

    final geometry = json["isInstancedBufferGeometry"] == true
        ? InstancedBufferGeometry()
        : BufferGeometry();

    final index = json["data"]["index"];

    if (index != null) {
      final typedArray = getTypedArray(index["type"], index["array"]);
      geometry.setIndex(getTypedAttribute(typedArray, 1, false));
    }

    final attributes = json["data"]["attributes"];

    for (final key in attributes.keys) {
      final attribute = attributes[key];
      BaseBufferAttribute bufferAttribute;

      if (attribute["isInterleavedBufferAttribute"] == true) {
        final interleavedBuffer =
            getInterleavedBuffer(json["data"], attribute["data"]);
        bufferAttribute = InterleavedBufferAttribute(
            interleavedBuffer,
            attribute["itemSize"],
            attribute["offset"],
            attribute["normalized"]);
      } else {
        final typedArray = getTypedArray(attribute["type"], attribute["array"]);
        // final bufferAttributeConstr = attribute.isInstancedBufferAttribute ? InstancedBufferAttribute : BufferAttribute;
        if (attribute["isInstancedBufferAttribute"] == true) {
          bufferAttribute = InstancedBufferAttribute(
              typedArray, attribute["itemSize"], attribute["normalized"]);
        } else {
          bufferAttribute = getTypedAttribute(typedArray, attribute["itemSize"],
              attribute["normalized"] == true);
        }
      }

      if (attribute["name"] != null) bufferAttribute.name = attribute["name"];
      if (attribute["usage"] != null) {
        if (bufferAttribute is InstancedBufferAttribute) {
          bufferAttribute.setUsage(attribute["usage"]);
        }
      }

      if (attribute["updateRange"] != null) {
        if (bufferAttribute is InterleavedBufferAttribute) {
          bufferAttribute.updateRange?['offset'] =
              attribute["updateRange"]["offset"];
          bufferAttribute.updateRange?['count'] =
              attribute["updateRange"]["count"];
        }
      }

      geometry.setAttribute(key, bufferAttribute);
    }

    final morphAttributes = json["data"]["morphAttributes"];

    if (morphAttributes != null) {
      for (final key in morphAttributes.keys) {
        final attributeArray = morphAttributes[key];

        final array = <BufferAttribute>[];

        for (int i = 0, il = attributeArray.length; i < il; i++) {
          final attribute = attributeArray[i];
          BufferAttribute bufferAttribute;

          if (attribute is InterleavedBufferAttribute) {
            final interleavedBuffer =
                getInterleavedBuffer(json["data"], attribute.data);
            bufferAttribute = InterleavedBufferAttribute(interleavedBuffer,
                attribute.itemSize, attribute.offset, attribute.normalized);
          } else {
            final typedArray = getTypedArray(attribute.type, attribute.array);
            bufferAttribute = getTypedAttribute(
                typedArray, attribute.itemSize, attribute.normalized);
          }

          if (attribute.name != null) bufferAttribute.name = attribute.name;
          array.add(bufferAttribute);
        }

        geometry.morphAttributes[key] = array;
      }
    }

    final morphTargetsRelative = json["data"]["morphTargetsRelative"];

    if (morphTargetsRelative == true) {
      geometry.morphTargetsRelative = true;
    }

    final groups = json["data"]["groups"] ??
        json["data"]["drawcalls"] ??
        json["data"]["offsets"];

    if (groups != null) {
      for (int i = 0, n = groups.length; i != n; ++i) {
        final group = groups[i];

        geometry.addGroup(
            group["start"], group["count"], group["materialIndex"]);
      }
    }

    final boundingSphere = json["data"]["boundingSphere"];

    if (boundingSphere != null) {
      final center = Vector3(0, 0, 0);

      if (boundingSphere["center"] != null) {
        center.fromArray(boundingSphere["center"]);
      }

      geometry.boundingSphere = Sphere(center, boundingSphere["radius"]);
    }

    if (json["name"] != null) geometry.name = json["name"];
    if (json["userData"] != null) geometry.userData = json["userData"];

    return geometry;
  }
}
