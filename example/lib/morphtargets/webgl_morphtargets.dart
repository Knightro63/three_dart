import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebglMorphtargets extends StatefulWidget {
  WebglMorphtargets({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  createState() => _State();
}

class _State extends State<WebglMorphtargets> {
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
  three_jsm.OrbitControls? controls;

  double dpr = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.PointLight light;

  three_jsm.VertexNormalsHelper? vnh;
  three_jsm.VertexTangentsHelper? vth;

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

  late three.Object3D model;

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
    renderer!.shadowMap.enabled = false;

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

  Future<void> initPage() async {
    scene = three.Scene();
    scene.background = three.Color(0x8FBCD4);

    camera = three.PerspectiveCamera(45, width / height, 1, 20);
    camera.position.z = 10;
    scene.add(camera);

    camera.lookAt(scene.position);

    scene.add(three.AmbientLight(0x8FBCD4, 0.4));

    final pointLight = three.PointLight(0xffffff, 1);
    camera.add(pointLight);

    final geometry = createGeometry();

    final material =
        three.MeshPhongMaterial({"color": 0xff0000, "flatShading": true});

    mesh = three.Mesh(geometry, material);
    scene.add(mesh);

    loaded = true;

    animate();

    // scene.overrideMaterial = new three.MeshBasicMaterial();
  }

  three.BoxGeometry createGeometry() {
    final geometry = three.BoxGeometry(2, 2, 2, 32, 32, 32);

    // create an empty array to  hold targets for the attribute we want to morph
    // morphing positions and normals is supported
    geometry.morphAttributes["position"] = [];

    // the original positions of the cube's vertices
    final positionAttribute = geometry.attributes["position"];

    // for the first morph target we'll move the cube's vertices onto the surface of a sphere
    List<double> spherePositions = [];

    // for the second morph target, we'll twist the cubes vertices
    List<double> twistPositions = [];
    final direction = three.Vector3(1, 0, 0);
    final vertex = three.Vector3();

    for (int i = 0; i < positionAttribute.count; i++) {
      final x = positionAttribute.getX(i);
      final y = positionAttribute.getY(i);
      final z = positionAttribute.getZ(i);

      spherePositions.addAll([
        x *
            three.Math.sqrt(
                1 - (y * y / 2) - (z * z / 2) + (y * y * z * z / 3)),
        y *
            three.Math.sqrt(
                1 - (z * z / 2) - (x * x / 2) + (z * z * x * x / 3)),
        z * three.Math.sqrt(1 - (x * x / 2) - (y * y / 2) + (x * x * y * y / 3))
      ]);

      // stretch along the x-axis so we can see the twist better
      vertex.set(x * 2, y, z);

      vertex
          .applyAxisAngle(direction, three.Math.pi * x / 2)
          .toArray(twistPositions, twistPositions.length);
    }

    // add the spherical positions as the first morph target
    // geometry.morphAttributes["position"][ 0 ] = new three.Float32BufferAttribute( spherePositions, 3 );
    geometry.morphAttributes["position"]!
        .add(three.Float32BufferAttribute(Float32Array.fromList(spherePositions), 3));

    // add the twisted positions as the second morph target
    geometry.morphAttributes["position"]!
        .add(three.Float32BufferAttribute(Float32Array.fromList(twistPositions), 3));

    return geometry;
  }

  void clickRender() {
    print("clickRender..... ");
    animate();
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    num _t = (DateTime.now().millisecondsSinceEpoch * 0.0005);

    final _v0 = (three.Math.sin(_t) + 1.0) / 2.0;
    final _v1 = (three.Math.sin(_t + 0.3) + 1.0) / 2.0;

    // print(" _v0: ${_v0} _v1: ${_v1} ");

    mesh.morphTargetInfluences![0] = _v0;
    mesh.morphTargetInfluences![1] = _v1;

    // mesh.morphTargetInfluences![0] = 0.2;

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
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
