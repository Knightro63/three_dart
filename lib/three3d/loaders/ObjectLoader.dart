part of three_loaders;

class ObjectLoader extends Loader {
  ObjectLoader([LoadingManager? manager]) : super(manager);

  @override
  dynamic load(url, Function onLoad, [Function? onProgress,Function? onError]) {
    final scope = this;

    final path = (this.path == '') ? LoaderUtils.extractUrlBase(url) : this.path;
    resourcePath = resourcePath ?? path;

    FileLoader loader = FileLoader(manager);
    loader.setPath(this.path);
    loader.setRequestHeader(requestHeader);
    loader.setWithCredentials(withCredentials);
    loader.load(
      url, 
      (text) {
        Map<String,dynamic> json;

        try {
          json = convert.jsonDecode(text);
        } catch (error) {
          if (onError != null) onError(error.toString());
          print('THREE:ObjectLoader: Can\'t parse $url.$error');
          return;
        }

        final metadata = json['metadata'];

        if (metadata == null ||
            metadata['type'] == null ||
            metadata['type'].toLowerCase() == 'geometry') {
          print('THREE.ObjectLoader: Can\'t load $url');
          return;
        }

        scope.parse(json, null, onLoad);
      }, 
      onProgress, 
      onError
    );
  }

  @override
  Future<Object3D> loadAsync(url) async {
    final scope = this;

    final path = (this.path == '') ? LoaderUtils.extractUrlBase(url) : this.path;
    resourcePath = resourcePath ?? path;

    final loader = FileLoader(manager);
    loader.setPath(this.path);
    loader.setRequestHeader(requestHeader);
    loader.setWithCredentials(withCredentials);

    final text = await loader.loadAsync(url);

    final json = convert.jsonDecode(text);

    final metadata = json['metadata'];

    if (metadata == null ||
        metadata['type'] == null ||
        metadata['type'].toLowerCase() == 'geometry') {
      throw ('THREE.ObjectLoader: Can\'t load ' + url);
    }

    return await scope.parseAsync(json);
  }

  Future<Object3D> parse(Map<String,dynamic> json, [String? path, Function? onLoad, void Function(String)? onError]) async {
    final animations = parseAnimations(json['animations']);
    final shapes = parseShapes(json['shapes']);
    final geometries = parseGeometries(json['geometries'], shapes);

    final images = await parseImages(json['images'], null);

    final textures = parseTextures(json['textures'], images);
    final materials = parseMaterials(json['materials'], textures);

    final object = parseObject(json['object'], geometries, materials, textures, animations);
    final skeletons = parseSkeletons(json['skeletons'], object);

    bindSkeletons(object, skeletons);

    return object;
  }

  Future<Object3D> parseAsync(Map<String, dynamic> json) async {
    final animations = parseAnimations(json["animations"]);
    final shapes = parseShapes(json["shapes"]);
    final geometries = parseGeometries(json["geometries"], shapes);

    // print(" ObjectLoader.parseAsync images1: ${json["images"]} ");

    final images = await parseImages(json["images"], null);

    // print(" ObjectLoader.parseAsync images2: ${images} ");

    if (images != null) {
      images.keys.forEach((k) {
        //final im = images[k];
        // print(" key: ${k} data: ${im.data} url: ${im.url} ");
      });
    }

    final textures = parseTextures(json["textures"], images);
    final materials = parseMaterials(json["materials"], textures);

    final object = parseObject(
        json["object"], geometries, materials, textures, animations);

    // final skeletons = this.parseSkeletons( json.skeletons, object );
    // this.bindSkeletons( object, skeletons );

    return object;
  }

  Map<String,Shape> parseShapes(json) {
    final Map<String,Shape> shapes = {};

    if (json != null) {
      for (int i = 0, l = json.length; i < l; i++) {
        final shape = Shape.fromJSON(json[i]);
        shapes[shape.uuid] = shape;
      }
    }

    return shapes;
  }

  parseSkeletons(json, object) {
    final skeletons = {};
    final Map<String, Bone?> bones = {};

    // generate bone lookup table

    object.traverse((child) {
      if (child is Bone) bones[child.uuid] = child;
    });

    // create skeletons

    if (json != null) {
      for (int i = 0, l = json.length; i < l; i++) {
        final skeleton = Skeleton().fromJSON(json[i], bones);

        skeletons[skeleton.uuid] = skeleton;
      }
    }

    return skeletons;
  }

  parseGeometries(json, shapes) {
    final geometries = {};

    if (json != null) {
      final bufferGeometryLoader = BufferGeometryLoader(null);

      for (int i = 0, l = json.length; i < l; i++) {
        late BufferGeometry geometry;
        Map<String, dynamic> data = json[i];

        switch (data["type"]) {
          case 'BufferGeometry':
          case 'InstancedBufferGeometry':
            geometry = bufferGeometryLoader._parse(data);

            break;

          case 'Geometry':
            print(
                'THREE.ObjectLoader: The legacy Geometry type is no longer supported.');

            break;

          default:
            if (data["type"] == "PlaneGeometry") {
              geometry = PlaneGeometry.fromJSON(data);
            } else if (data["type"] == "BoxGeometry") {
              geometry = BoxGeometry.fromJSON(data);
            } else if (data["type"] == "CylinderGeometry") {
              geometry = CylinderGeometry.fromJSON(data);
            } else if (data["type"] == "SphereGeometry") {
              geometry = SphereGeometry.fromJSON(data);
            } else {
              throw ("THREE.ObjectLoader: Unsupported geometry type ${data["type"]}");
            }
        }

        geometry.uuid = data["uuid"];

        if (data["name"] != null) geometry.name = data["name"];
        if (geometry is BufferGeometry && data["userData"] != null) {
          geometry.userData = data["userData"];
        }

        geometries[data["uuid"]] = geometry;
      }
    }

    return geometries;
  }

  parseMaterials(json, textures) {
    final cache = {}; // MultiMaterial
    final materials = {};

    if (json != null) {
      final loader = MaterialLoader(null);
      loader.setTextures(textures);

      for (int i = 0, l = json.length; i < l; i++) {
        Map<String, dynamic> data = json[i];

        if (data["type"] == 'MultiMaterial') {
          // Deprecated

          final array = [];

          for (int j = 0; j < data["materials"].length; j++) {
            final material = data["materials"][j];

            if (cache[material.uuid] == null) {
              cache[material.uuid] = loader.parse(material);
            }

            array.add(cache[material.uuid]);
          }

          materials[data["uuid"]] = array;
        } else {
          if (cache[data["uuid"]] == null) {
            cache[data["uuid"]] = loader.parse(data);
          }

          materials[data["uuid"]] = cache[data["uuid"]];
        }
      }
    }

    return materials;
  }

  parseAnimations(json) {
    final animations = {};

    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        final data = json[i];

        final clip = AnimationClip.parse(data);

        animations[clip.uuid] = clip;
      }
    }

    return animations;
  }

  parseImages(json, onLoad) async {
    final scope = this;
    final images = {};

    late ImageLoader loader;

    loadImage(url) async {
      scope.manager.itemStart(url);

      return await loader.loadAsync(url, (progress) {
        scope.manager.itemEnd(url);
      });
    }

    deserializeImage(image) async {
      if (image is String) {
        final url = image;

        final path =
            RegExp("^(//)|([a-z]+:(//)?)", caseSensitive: false).hasMatch(url)
                ? url
                : (scope.resourcePath ?? "") + url;

        return await loadImage(path);
      } else {
        if (image.data) {
          return {
            "data": getTypedArray(image.type, image.data),
            "width": image.width,
            "height": image.height
          };
        } else {
          return null;
        }
      }
    }

    if (json != null && json.length > 0) {
      final manager = LoadingManager(onLoad, null, null);

      loader = ImageLoader(manager);
      loader.setCrossOrigin(crossOrigin);

      for (int i = 0, il = json.length; i < il; i++) {
        Map<String, dynamic> image = json[i];
        final url = image["url"];

        if (url is List) {
          // load array of images e.g CubeTexture

          List imageArray = [];

          for (int j = 0, jl = url.length; j < jl; j++) {
            final currentUrl = url[j];

            final deserializedImage = await deserializeImage(currentUrl);

            if (deserializedImage != null) {
              imageArray.add(deserializedImage);

              // if ( deserializedImage is HTMLImageElement ) {

              // 	imageArray.push( deserializedImage );

              // } else {

              // 	// special case: handle array of data textures for cube textures

              // 	imageArray.push( new DataTexture( deserializedImage.data, deserializedImage.width, deserializedImage.height ) );

              // }

            }
          }

          images[image["uuid"]] = Source(imageArray);
        } else {
          // load single image

          final deserializedImage = await deserializeImage(image["url"]);

          if (deserializedImage != null) {
            images[image["uuid"]] = Source(deserializedImage);
          }
        }
      }
    }

    return images;
  }

  Map parseTextures(json, images) {
    parseConstant(value, type) {
      if (value is num) return value;

      print(
          'THREE.ObjectLoader.parseTexture: Constant should be in numeric form. $value');

      return type[value];
    }

    final textures = {};

    if (json != null) {
      for (int i = 0, l = json.length; i < l; i++) {
        Map<String, dynamic> data = json[i];

        if (data['image'] == null) {
          print('THREE.ObjectLoader: No "image" specified for ${data["uuid"]}');
        }

        if (images[data["image"]] == null) {
          print('THREE.ObjectLoader: Undefined image ${data["image"]}');
        }

        Texture texture;

        final source = images[data["image"]];
        final image = source.data;

        if (image is List) {
          texture = CubeTexture();

          if (image.length == 6) texture.needsUpdate = true;
        } else {
          if (image != null && image.data != null && image.url == null) {
            texture = DataTexture();
          } else {
            texture = Texture();
          }

          if (image != null) {
            texture.needsUpdate = true;
          } // textures can have null image data

        }

        texture.source = source;
        texture.uuid = data["uuid"];

        if (data["name"] != null) texture.name = data["name"];

        if (data["mapping"] != null) {
          texture.mapping = parseConstant(data["mapping"], textureMapping);
        }

        if (data["offset"] != null) texture.offset.fromArray(data["offset"]);
        if (data["repeat"] != null) texture.repeat.fromArray(data["repeat"]);
        if (data["center"] != null) texture.center.fromArray(data["center"]);
        if (data["rotation"] != null) texture.rotation = data["rotation"];

        if (data["wrap"] != null) {
          texture.wrapS = parseConstant(data["wrap"][0], textureWrapping);
          texture.wrapT = parseConstant(data["wrap"][1], textureWrapping);
        }

        if (data["format"] != null) texture.format = data["format"];
        if (data["type"] != null) texture.type = data["type"];
        if (data["encoding"] != null) texture.encoding = data["encoding"];

        if (data["minFilter"] != null) {
          texture.minFilter = parseConstant(data["minFilter"], textureFilter);
        }
        if (data["magFilter"] != null) {
          texture.magFilter = parseConstant(data["magFilter"], textureFilter);
        }
        if (data["anisotropy"] != null) texture.anisotropy = data["anisotropy"];

        if (data["flipY"] != null) texture.flipY = data["flipY"];

        if (data["premultiplyAlpha"] != null) {
          texture.premultiplyAlpha = data["premultiplyAlpha"];
        }
        if (data["unpackAlignment"] != null) {
          texture.unpackAlignment = data["unpackAlignment"];
        }
        if (data["userData"] != null) texture.userData = data["userData"];

        textures[data["uuid"]] = texture;
      }
    }

    return textures;
  }

  Object3D parseObject(
      Map<String, dynamic> data, geometries, materials, textures, animations) {
    dynamic object;

    getGeometry(name) {
      if (geometries[name] == null) {
        print('THREE.ObjectLoader: Undefined geometry $name');
      }

      return geometries[name];
    }

    getMaterial(name) {
      if (name == null) return null;

      if (name is List) {
        final array = [];

        for (int i = 0, l = name.length; i < l; i++) {
          final uuid = name[i];

          if (materials[uuid] == null) {
            print('THREE.ObjectLoader: Undefined material $uuid');
          }

          array.add(materials[uuid]);
        }

        return array;
      }

      if (materials[name] == null) {
        print('THREE.ObjectLoader: Undefined material $name');
      }

      return materials[name];
    }

    getTexture(uuid) {
      if (textures[uuid] == null) {
        print('THREE.ObjectLoader: Undefined texture $uuid');
      }

      return textures[uuid];
    }

    final geometry, material;

    switch (data["type"]) {
      case 'Scene':
        object = Scene();

        if (data["background"] != null) {
          if (data["background"] is int) {
            object.background = Color.fromHex(data["background"]);
          } else {
            object.background = getTexture(data["background"]);
          }
        }

        if (data["environment"] != null) {
          object.environment = getTexture(data["environment"]);
        }

        if (data["fog"] != null) {
          if (data["fog"]["type"] == 'Fog') {
            object.fog = Fog(
                data["fog"]["color"], data["fog"]["near"], data["fog"]["far"]);
          } else if (data["fog"]["type"] == 'FogExp2') {
            object.fog = FogExp2(data["fog"]["color"], data["fog"]["density"]);
          }
        }

        break;

      case 'PerspectiveCamera':
        object = PerspectiveCamera(
            data["fov"], data["aspect"], data["near"], data["far"]);

        if (data["focus"] != null) object.focus = data["focus"];
        if (data["zoom"] != null) object.zoom = data["zoom"];
        if (data["filmGauge"] != null) object.filmGauge = data["filmGauge"];
        if (data["filmOffset"] != null) object.filmOffset = data["filmOffset"];
        if (data["view"] != null) {
          object.view = convert.jsonDecode(convert.jsonEncode(data["view"]));
        }

        break;

      case 'OrthographicCamera':
        object = OrthographicCamera(data["left"], data["right"], data["top"],
            data["bottom"], data["near"], data["far"]);

        if (data["zoom"] != null) object.zoom = data["zoom"];
        if (data["view"] != null) {
          object.view = convert.jsonDecode(convert.jsonEncode(data["view"]));
        }

        break;

      case 'AmbientLight':
        object = AmbientLight(data["color"], data["intensity"]);

        break;

      case 'DirectionalLight':
        object = DirectionalLight(data["color"], data["intensity"]);

        break;

      case 'PointLight':
        object = PointLight(
            data["color"], data["intensity"], data["distance"], data["decay"]);

        break;

      case 'RectAreaLight':
        object = RectAreaLight(
            data["color"], data["intensity"], data["width"], data["height"]);

        break;

      case 'SpotLight':
        object = SpotLight(data["color"], data["intensity"], data["distance"],
            data["angle"], data["penumbra"], data["decay"]);

        break;

      case 'HemisphereLight':
        object = HemisphereLight(
            data["color"], data["groundColor"], data["intensity"]);

        break;

      case 'LightProbe':
        object = LightProbe.fromJSON(data);

        break;

      case 'SkinnedMesh':
        geometry = getGeometry(data["geometry"]);
        material = getMaterial(data["material"]);

        object = SkinnedMesh(geometry, material);

        if (data["bindMode"] != null) object.bindMode = data["bindMode"];
        if (data["bindMatrix"] != null) {
          object.bindMatrix.fromArray(data["bindMatrix"]);
        }
        if (data["skeleton"] != null) object.skeleton = data["skeleton"];

        break;

      case 'Mesh':
        geometry = getGeometry(data["geometry"]);
        material = getMaterial(data["material"]);

        object = Mesh(geometry, material);

        break;

      case 'InstancedMesh':
        geometry = getGeometry(data["geometry"]);
        material = getMaterial(data["material"]);
        final count = data["count"];
        final instanceMatrix = data["instanceMatrix"];
        final instanceColor = data["instanceColor"];

        object = InstancedMesh(geometry, material, count);
        object.instanceMatrix = InstancedBufferAttribute(
            Float32Array(instanceMatrix.array), 16, false);
        if (instanceColor != null) {
          object.instanceColor = InstancedBufferAttribute(
              Float32Array(instanceColor.array), instanceColor.itemSize, false);
        }

        break;

      // case 'LOD':

      // 	object = new LOD();

      // 	break;

      case 'Line':
        object =
            Line(getGeometry(data["geometry"]), getMaterial(data["material"]));

        break;

      case 'LineLoop':
        object = LineLoop(
            getGeometry(data["geometry"]), getMaterial(data["material"]));

        break;

      case 'LineSegments':
        object = LineSegments(
            getGeometry(data["geometry"]), getMaterial(data["material"]));

        break;

      case 'PointCloud':
      case 'Points':
        object = Points(
            getGeometry(data["geometry"]), getMaterial(data["material"]));

        break;

      case 'Sprite':
        object = Sprite(getMaterial(data["material"]));

        break;

      case 'Group':
        object = Group();

        break;

      case 'Bone':
        object = Bone();

        break;

      default:
        object = Object3D();
    }

    object.uuid = data["uuid"];

    if (data["name"] != null) object.name = data["name"];

    if (data["matrix"] != null) {
      object.matrix.fromArray(data["matrix"]);

      if (data["matrixAutoUpdate"] != null) {
        object.matrixAutoUpdate = data["matrixAutoUpdate"];
      }
      if (object.matrixAutoUpdate) {
        object.matrix
            .decompose(object.position, object.quaternion, object.scale);
      }
    } else {
      if (data["position"] != null) object.position.fromArray(data["position"]);
      if (data["rotation"] != null) object.rotation.fromArray(data["rotation"]);
      if (data["quaternion"] != null) {
        object.quaternion.fromArray(data["quaternion"]);
      }
      if (data["scale"] != null) object.scale.fromArray(data["scale"]);
    }

    if (data["castShadow"] != null) object.castShadow = data["castShadow"];
    if (data["receiveShadow"] != null) {
      object.receiveShadow = data["receiveShadow"];
    }

    if (data["shadow"] != null) {
      if (data["shadow"]["bias"] != null) {
        object.shadow.bias = data["shadow"]["bias"];
      }
      if (data["shadow"]["normalBias"] != null) {
        object.shadow.normalBias = data["shadow"]["normalBias"];
      }
      if (data["shadow"]["radius"] != null) {
        object.shadow.radius = data["shadow"]["radius"];
      }
      if (data["shadow"]["mapSize"] != null) {
        object.shadow.mapSize.fromArray(data["shadow"]["mapSize"]);
      }
      if (data["shadow"]["camera"] != null) {
        object.shadow.camera =
            parseObject(data["shadow"]["camera"], null, null, null, null);
      }
    }

    if (data["visible"] != null) object.visible = data["visible"];
    if (data["frustumCulled"] != null) {
      object.frustumCulled = data["frustumCulled"];
    }
    if (data["renderOrder"] != null) object.renderOrder = data["renderOrder"];
    if (data["userData"] != null) object.userData = data["userData"];
    if (data["layers"] != null) object.layers.mask = data["layers"];

    if (data["children"] != null) {
      final children = data["children"];

      for (int i = 0; i < children.length; i++) {
        object.add(parseObject(
            children[i], geometries, materials, textures, animations));
      }
    }

    if (data["animations"] != null) {
      final objectAnimations = data["animations"];

      for (int i = 0; i < objectAnimations.length; i++) {
        final uuid = objectAnimations[i];

        object.animations.push(animations[uuid]);
      }
    }

    if (data["type"] == 'LOD') {
      if (data["autoUpdate"] != null) object.autoUpdate = data["autoUpdate"];

      final levels = data["levels"];

      for (int l = 0; l < levels.length; l++) {
        final level = levels[l];
        final child = object.getObjectByProperty('uuid', level.object);

        if (child != null) {
          object.addLevel(child, level.distance);
        }
      }
    }

    return object;
  }

  bindSkeletons(object, skeletons) {
    if (skeletons.keys.length == 0) return;

    object.traverse((child) {
      if (child is SkinnedMesh && child.skeleton != null) {
        final skeleton = skeletons[child.skeleton];

        if (skeleton == null) {
          print(
              'THREE.ObjectLoader: No skeleton found with UUID: ${child.skeleton}');
        } else {
          child.bind(skeleton, child.bindMatrix);
        }
      }
    });
  }

  /* DEPRECATED */

  setTexturePath(value) {
    print(
        'THREE.ObjectLoader: .setTexturePath() has been renamed to .setResourcePath().');
    return setResourcePath(value);
  }
}

final textureMapping = {
  "UVMapping": UVMapping,
  "CubeReflectionMapping": CubeReflectionMapping,
  "CubeRefractionMapping": CubeRefractionMapping,
  "EquirectangularReflectionMapping": EquirectangularReflectionMapping,
  "EquirectangularRefractionMapping": EquirectangularRefractionMapping,
  "CubeUVReflectionMapping": CubeUVReflectionMapping
};

final textureWrapping = {
  "RepeatWrapping": RepeatWrapping,
  "ClampToEdgeWrapping": ClampToEdgeWrapping,
  "MirroredRepeatWrapping": MirroredRepeatWrapping
};

final textureFilter = {
  "NearestFilter": NearestFilter,
  "NearestMipmapNearestFilter": NearestMipmapNearestFilter,
  "NearestMipmapLinearFilter": NearestMipmapLinearFilter,
  "LinearFilter": LinearFilter,
  "LinearMipmapNearestFilter": LinearMipmapNearestFilter,
  "LinearMipmapLinearFilter": LinearMipmapLinearFilter
};
