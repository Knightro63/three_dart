import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglCamera extends StatefulWidget {
  WebglCamera({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglCamera> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.Camera cameraPerspective;
  late three.Camera cameraOrtho;

  late three.Group cameraRig;

  late three.Camera activeCamera;
  late three.CameraHelper activeHelper;

  late three.CameraHelper cameraOrthoHelper;
  late three.CameraHelper cameraPerspectiveHelper;

  int frustumSize = 600;

  double dpr = 1.0;

  num aspect = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

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

    final r = DateTime.now().millisecondsSinceEpoch * 0.0005;

    mesh.position.x = 700 * three.Math.cos(r);
    mesh.position.z = 700 * three.Math.sin(r);
    mesh.position.y = 700 * three.Math.sin(r);

    mesh.children[0].position.x = 70 * three.Math.cos(2 * r);
    mesh.children[0].position.z = 70 * three.Math.sin(r);

    if (activeCamera == cameraPerspective) {
      cameraPerspective.fov = 35 + 30 * three.Math.sin(0.5 * r);
      cameraPerspective.far = mesh.position.length();
      cameraPerspective.updateProjectionMatrix();

      cameraPerspectiveHelper.update();
      cameraPerspectiveHelper.visible = true;

      cameraOrthoHelper.visible = false;
    } else {
      cameraOrtho.far = mesh.position.length();
      cameraOrtho.updateProjectionMatrix();

      cameraOrthoHelper.update();
      cameraOrthoHelper.visible = true;

      cameraPerspectiveHelper.visible = false;
    }

    cameraRig.lookAt(mesh.position);

    renderer!.clear();

    activeHelper.visible = false;

    renderer!.setViewport(0, 0, width / 2, height);
    renderer!.render(scene, activeCamera);

    activeHelper.visible = true;

    renderer!.setViewport(width / 2, 0, width / 2, height);
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
    renderer!.autoClear = false;

    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({
        "minFilter": three.LinearFilter,
        "magFilter": three.LinearFilter,
        "format": three.RGBAFormat,
        "samples": 4
      });
      renderTarget = three.WebGLRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  void initScene() {
    initRenderer();
    initPage();
  }

  void initPage() {
    aspect = width / height;

    scene = three.Scene();

    //

    camera = three.PerspectiveCamera(50, 0.5 * aspect, 1, 10000);
    camera.position.z = 2500;

    cameraPerspective =
        three.PerspectiveCamera(50, 0.5 * aspect, 150, 1000);

    cameraPerspectiveHelper = three.CameraHelper(cameraPerspective);
    scene.add(cameraPerspectiveHelper);

    //
    cameraOrtho = three.OrthographicCamera(
        0.5 * frustumSize * aspect / -2,
        0.5 * frustumSize * aspect / 2,
        frustumSize / 2,
        frustumSize / -2,
        150,
        1000);

    cameraOrthoHelper = three.CameraHelper(cameraOrtho);
    scene.add(cameraOrthoHelper);

    //

    activeCamera = cameraPerspective;
    activeHelper = cameraPerspectiveHelper;

    // counteract different front orientation of cameras vs rig

    cameraOrtho.rotation.y = three.Math.pi;
    cameraPerspective.rotation.y = three.Math.pi;

    cameraRig = three.Group();

    cameraRig.add(cameraPerspective);
    cameraRig.add(cameraOrtho);

    scene.add(cameraRig);

    //

    mesh = three.Mesh(three.SphereGeometry(100, 16, 8),
        three.MeshBasicMaterial({"color": 0xffffff, "wireframe": true}));
    scene.add(mesh);

    final mesh2 = three.Mesh(three.SphereGeometry(50, 16, 8),
        three.MeshBasicMaterial({"color": 0x00ff00, "wireframe": true}));
    mesh2.position.y = 150;
    mesh.add(mesh2);

    final mesh3 = three.Mesh(three.SphereGeometry(5, 16, 8),
        three.MeshBasicMaterial({"color": 0x0000ff, "wireframe": true}));
    mesh3.position.z = 150;
    cameraRig.add(mesh3);

    //

    final geometry = three.BufferGeometry();
    List<double> vertices = [];

    for (int i = 0; i < 10000; i++) {
      vertices.add(three.MathUtils.randFloatSpread(2000)); // x
      vertices.add(three.MathUtils.randFloatSpread(2000)); // y
      vertices.add(three.MathUtils.randFloatSpread(2000)); // z

    }

    geometry.setAttribute(
        'position', three.Float32BufferAttribute(Float32Array.fromList(vertices), 3));

    final particles = three.Points(
        geometry, three.PointsMaterial({"color": 0x888888}));
    scene.add(particles);

    animate();
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

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
          render();
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
                  })),
            ],
          ),
        ),
      ],
    );
  }
}
