import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglCameraArray extends StatefulWidget {
  WebglCameraArray({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglCameraArray> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  double dpr = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

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
    height = width;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    print("three3dRender.initialize _options: $_options ");

    await three3dRender.initialize(options: _options);

     print("three3dRender.initialize three3dRender: ${three3dRender.textureId} ");


    setState(() {});

    Future.delayed(const Duration(milliseconds: 200), () async {
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

    _gl.finish();

    if (verbose) print(" render: sourceTexture: $sourceTexture three3dRender.textureId! ${three3dRender.textureId!}");

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

    print('initRenderer  dpr: $dpr _options: $_options');

    renderer = three.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({
        "format": three.RGBAFormat
      });
      renderTarget = three.WebGLRenderTarget(
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

  void initPage() {
    final aspectRatio = this.width / this.height;

    final width = (this.width / amount) * dpr;
    final height = (this.height / amount) * dpr;

    List<three.Camera> cameras = [];

    for (int y = 0; y < amount; y++) {
      for (int x = 0; x < amount; x++) {
        final subcamera = three.PerspectiveCamera(40, aspectRatio, 0.1, 10);
        subcamera.viewport = three.Vector4(
          three.Math.floor(x * width),
          three.Math.floor(y * height),
          three.Math.ceil(width),
          three.Math.ceil(height)
        );
        subcamera.position.x = (x / amount) - 0.5;
        subcamera.position.y = 0.5 - (y / amount);
        subcamera.position.z = 1.5;
        subcamera.position.multiplyScalar(2);
        subcamera.lookAt(three.Vector3(0, 0, 0));
        subcamera.updateMatrixWorld(false);
        cameras.add(subcamera);
      }
    }

    camera = three.ArrayCamera(cameras);
    // camera = new three.PerspectiveCamera(45, width / height, 1, 10);
    camera.position.z = 3;

    scene = three.Scene();

    final ambientLight = three.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    camera.lookAt(scene.position);

    final light = three.DirectionalLight(0xffffff, null);
    light.position.set(0.5, 0.5, 1);
    light.castShadow = true;
    light.shadow!.camera!.zoom = 4; // tighter shadow map
    scene.add(light);

    final geometryBackground = three.PlaneGeometry(100, 100);
    final materialBackground = three.MeshPhongMaterial({"color": 0x000066});

    final background = three.Mesh(geometryBackground, materialBackground);
    background.receiveShadow = true;
    background.position.set(0, 0, -1);
    scene.add(background);

    final geometryCylinder = three.CylinderGeometry(0.5, 0.5, 1, 32);
    final materialCylinder = three.MeshPhongMaterial({"color": 0xff0000});

    mesh = three.Mesh(geometryCylinder, materialCylinder);
    // mesh.castShadow = true;
    // mesh.receiveShadow = true;
    scene.add(mesh);
     

    loaded = true;
    animate();
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    mesh.rotation.x += 0.1;
    mesh.rotation.y += 0.05;

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
          animate();
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
                  width: width,
                  height: height,
                  color: Colors.red,
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized
                          ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                          : Container(color: Colors.red,);
                    } else {
                      return three3dRender.isInitialized
                          ? Texture(textureId: three3dRender.textureId!)
                          : Container(color: Colors.red);
                    }
                  })),
            ],
          ),
        ),
      ],
    );
  }
}
