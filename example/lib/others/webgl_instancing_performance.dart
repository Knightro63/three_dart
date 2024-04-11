import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglInstancingPerformance extends StatefulWidget {
  WebglInstancingPerformance({Key? key, required this.fileName})
      : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglInstancingPerformance> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.Material material;

  double dpr = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  int count = 1000;

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
      final pars = three.WebGLRenderTargetOptions({
        "minFilter": three.LinearFilter,
        "magFilter": three.LinearFilter,
        "format": three.RGBAFormat
      });
      renderTarget = three.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  Future<void> initScene() async {
    initRenderer();
    await initPage();
  }

  Future<void> initPage() async {
    camera = three.PerspectiveCamera(70, width / height, 1, 100);
    camera.position.z = 30;

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xffffff);

    //final _loader = three.BufferGeometryLoader(null);
    material = three.MeshNormalMaterial();

    // final geometry = await _loader.loadAsync("assets/models/json/suzanne_buffergeometry.json", null);
    // geometry.computeVertexNormals();

    final geometry = three.BoxGeometry(5, 5, 5);

    // makeInstanced( geometry );

    // makeMerged( geometry );

    makeNaive(geometry);

    animate();
  }

  void makeInstanced(geometry) {
    final matrix = three.Matrix4();
    final mesh = three.InstancedMesh(geometry, material, count);

    for (int i = 0; i < count; i++) {
      randomizeMatrix(matrix);
      mesh.setMatrixAt(i, matrix);
    }

    scene.add(mesh);
  }

  void makeNaive(geometry) {
    final matrix = three.Matrix4();

    for (int i = 0; i < count; i++) {
      final mesh = three.Mesh(geometry, material);
      randomizeMatrix(matrix);
      mesh.applyMatrix4(matrix);
      scene.add(mesh);
    }
  }

  final position = three.Vector3();
  final rotation = three.Euler(0, 0, 0);
  final quaternion = three.Quaternion();
  final scale = three.Vector3();

  void randomizeMatrix(matrix) {
    position.x = three.Math.random() * 40 - 20;
    position.y = three.Math.random() * 40 - 20;
    position.z = three.Math.random() * 40 - 20;

    rotation.x = three.Math.random() * 2 * three.Math.pi;
    rotation.y = three.Math.random() * 2 * three.Math.pi;
    rotation.z = three.Math.random() * 2 * three.Math.pi;

    quaternion.setFromEuler(rotation, false);

    scale.x = scale.y = scale.z = three.Math.random() * 1;

    matrix.compose(position, quaternion, scale);
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

    scene.rotation.x += 0.002;
    scene.rotation.y += 0.001;

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
