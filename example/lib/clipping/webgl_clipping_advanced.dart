import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglClippingAdvanced extends StatefulWidget {
  WebglClippingAdvanced({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  createState() => _State();
}

class _State extends State<WebglClippingAdvanced> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.AnimationMixer mixer;
  three.Clock clock = three.Clock();

  double dpr = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

  late three.Object3D model;

  late three.MeshPhongMaterial clipMaterial;

  int startTime = 0;

  dynamic volumeVisualization, globalClippingPlanes;

  final Map<String, List<Function>> listeners = {};

  late List<three.Plane> _Planes;

  late List<three.Matrix4> _PlaneMatrices;
  late List<three.Plane> GlobalClippingPlanes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();
      initScene();
    });
  }

  void initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  void render() {
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    _gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  void initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;
    renderer!.localClippingEnabled = true;
    renderer!.clippingPlanes = [];

    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  void initScene() {
    initRenderer();
    initPage();
  }

  planesFromMesh(vertices, indices) {
    // creates a clipping volume from a convex triangular mesh
    // specified by the arrays 'vertices' and 'indices'
    int n = indices.length ~/ 3;
    final result = List<three.Plane>.filled(n, three.Plane(null, null));

    for (int i = 0, j = 0; i < n; ++i, j += 3) {
      final a = vertices[indices[j]],
          b = vertices[indices[j + 1]],
          c = vertices[indices[j + 2]];

      result[i] = three.Plane(null, null).setFromCoplanarPoints(a, b, c);
    }

    return result;
  }

  createPlanes(n) {
    // reates an array of n uninitialized plane objects
    final result = List<three.Plane>.filled(n, three.Plane(null, null));
    // for ( int i = 0; i != n; ++ i )
    //   result[ i ] = new three.Plane(null, null);
    return result;
  }

  void assignTransformedPlanes(planesOut, planesIn, matrix) {
    // sets an array of existing planes to transformed 'planesIn'
    for (int i = 0, n = planesIn.length; i != n; ++i) {
      planesOut[i].copy(planesIn[i]).applyMatrix4(matrix, null);
    }
  }

  cylindricalPlanes(n, double innerRadius) {
    final result = createPlanes(n);

    for (int i = 0; i != n; ++i) {
      final plane = result[i], angle = i * three.Math.pi * 2 / n;

      plane.normal.set(three.Math.cos(angle), 0.0, three.Math.sin(angle));

      plane.constant = innerRadius;
    }

    return result;
  }

  final xAxis = three.Vector3(),
      yAxis = three.Vector3(),
      trans = three.Vector3();

  three.Matrix4 planeToMatrix(plane) {
    final zAxis = plane.normal, matrix = three.Matrix4();

    // Hughes & Moeller '99
    // "Building an Orthonormal Basis from a Unit Vector."

    if (three.Math.abs(zAxis.x) > three.Math.abs(zAxis.z)) {
      yAxis.set(-zAxis.y, zAxis.x, 0);
    } else {
      yAxis.set(0, -zAxis.z, zAxis.y);
    }

    xAxis.crossVectors(yAxis.normalize(), zAxis);

    plane.coplanarPoint(trans);
    return matrix.set(xAxis.x, yAxis.x, zAxis.x, trans.x, xAxis.y, yAxis.y,
        zAxis.y, trans.y, xAxis.z, yAxis.z, zAxis.z, trans.z, 0, 0, 0, 1);
  }

  Future<void> initPage() async {
    final Vertices = [
          three.Vector3(1, 0, three.Math.sqrt1_2),
          three.Vector3(-1, 0, three.Math.sqrt1_2),
          three.Vector3(0, 1, -three.Math.sqrt1_2),
          three.Vector3(0, -1, -three.Math.sqrt1_2)
        ],
        Indices = [0, 1, 2, 0, 2, 3, 0, 3, 1, 1, 3, 2];

    _Planes = planesFromMesh(Vertices, Indices);

    _PlaneMatrices = _Planes.map(planeToMatrix).toList();

    GlobalClippingPlanes = cylindricalPlanes(5, 2.5);

    //var Empty = [];

    camera = three.PerspectiveCamera(45, width / height, 0.25, 16);

    camera.position.set(0, 1.5, 5);

    scene = three.Scene();

    // Lights

    camera.lookAt(scene.position);

    scene.add(three.AmbientLight(0xffffff, 0.3));

    final spotLight = three.SpotLight(0xffffff, 0.5);
    spotLight.angle = three.Math.pi / 5;
    spotLight.penumbra = 0.2;
    spotLight.position.set(2, 3, 3);
    spotLight.castShadow = true;
    spotLight.shadow!.camera!.near = 3;
    spotLight.shadow!.camera!.far = 10;
    spotLight.shadow!.mapSize.width = 1024;
    spotLight.shadow!.mapSize.height = 1024;
    scene.add(spotLight);

    final dirLight = three.DirectionalLight(0xffffff, 0.5);
    dirLight.position.set(0, 2, 0);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.near = 1;
    dirLight.shadow!.camera!.far = 10;

    dirLight.shadow!.camera!.right = 1;
    dirLight.shadow!.camera!.left = -1;
    dirLight.shadow!.camera!.top = 1;
    dirLight.shadow!.camera!.bottom = -1;

    dirLight.shadow!.mapSize.width = 1024;
    dirLight.shadow!.mapSize.height = 1024;
    scene.add(dirLight);

    // Geometry

    clipMaterial = three.MeshPhongMaterial({
      "color": 0xee0a10,
      "shininess": 100,
      "side": three.DoubleSide,
      // Clipping setup:
      "clippingPlanes": createPlanes(_Planes.length),
      "clipShadows": true
    });

    object = three.Group();

    final geometry = three.BoxGeometry(0.18, 0.18, 0.18);

    for (int z = -2; z <= 2; ++z)
      for (int y = -2; y <= 2; ++y) {
        for (int x = -2; x <= 2; ++x) {
          final mesh = three.Mesh(geometry, clipMaterial);
          mesh.position.set(x / 5, y / 5, z / 5);
          mesh.castShadow = true;
          object.add(mesh);
        }
      }

    scene.add(object);

    final planeGeometry = three.PlaneGeometry(3, 3, 1, 1),
        color = three.Color(0, 0, 0);

    volumeVisualization = three.Group();
    volumeVisualization.visible = true;

    for (int i = 0, n = _Planes.length; i != n; ++i) {
      List<three.Plane> __clippingPlanes = [];

      clipMaterial.clippingPlanes!.asMap().forEach((index, elm) {
        if (index != i) {
          __clippingPlanes.add(elm);
        }
      });

      final material = three.MeshBasicMaterial({
        "color": color.setHSL(i / n, 0.5, 0.5).getHex(),
        "side": three.DoubleSide,

        "opacity": 0.2,
        "transparent": true,

        // clip to the others to show the volume (wildly
        // intersecting transparent planes look bad)
        "clippingPlanes": __clippingPlanes

        // no need to enable shadow clipping - the plane
        // visualization does not cast shadows
      });

      final mesh = three.Mesh(planeGeometry, material);
      mesh.matrixAutoUpdate = false;

      volumeVisualization.add(mesh);
    }

    scene.add(volumeVisualization);

    final ground = three.Mesh(planeGeometry,
        three.MeshPhongMaterial({"color": 0xa0adaf, "shininess": 10}));
    ground.rotation.x = -three.Math.pi / 2;
    ground.scale.multiplyScalar(3);
    ground.receiveShadow = true;
    scene.add(ground);

    globalClippingPlanes = createPlanes(GlobalClippingPlanes.length);

    startTime = DateTime.now().millisecondsSinceEpoch;

    loaded = true;

    animate();

    // scene.overrideMaterial = new three.MeshBasicMaterial();
  }

  void clickRender() {
    print("clickRender..... ");
    animate();
  }

  void setObjectWorldMatrix(object, matrix) {
    // set the orientation of an object based on a world matrix

    final parent = object.parent;
    scene.updateMatrixWorld(false);
    object.matrix.copy(parent.matrixWorld).invert();
    object.applyMatrix4(matrix);
  }

  final transform = three.Matrix4(), tmpMatrix = three.Matrix4();

  void animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch,
        time = (currentTime - startTime) / 1000;

    object.position.y = 1;
    object.rotation.x = time * 0.5;
    object.rotation.y = time * 0.2;

    object.updateMatrix();
    transform.copy(object.matrix);

    final bouncy = three.Math.cos(time * .5) * 0.5 + 0.7;
    transform.multiply(tmpMatrix.makeScale(bouncy, bouncy, bouncy));

    assignTransformedPlanes(clipMaterial.clippingPlanes, _Planes, transform);

    final planeMeshes = volumeVisualization.children;
    final n = planeMeshes.length;

    for (int i = 0; i < n; ++i) {
      tmpMatrix.multiplyMatrices(transform, _PlaneMatrices[i]);
      setObjectWorldMatrix(planeMeshes[i], tmpMatrix);
    }

    transform.makeRotationY(time * 0.1);

    assignTransformedPlanes(
        globalClippingPlanes, GlobalClippingPlanes, transform);

    render();

    // Future.delayed(Duration(milliseconds: 40), () {
    //   animate();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("render"),
        onPressed: () {
          clickRender();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Container(
                  child: Container(
                      width: width,
                      height: height,
                      color: Colors.black,
                      child: Builder(builder: (BuildContext context) {
                        if (kIsWeb) {
                          return three3dRender.isInitialized
                              ? HtmlElementView(
                                  viewType: three3dRender.textureId!.toString())
                              : Container();
                        } else {
                          return three3dRender.isInitialized
                              ? Texture(textureId: three3dRender.textureId!)
                              : Container();
                        }
                      }))),
            ],
          ),
        ),
      ],
    );
  }
}
