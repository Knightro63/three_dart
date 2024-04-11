import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglGeometryColors extends StatefulWidget {
  WebglGeometryColors({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglGeometryColors> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.PointLight pointLight;

  final objects = [];
  final materials = [];

  double dpr = 1.0;

  final int amount = 4;

  bool verbose = false;
  bool disposed = false;

  bool loaded = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  three.AnimationMixer? mixer;
  three.Clock clock = three.Clock();

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

  void clickRender() {
    print(" click render... ");
    animate();
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
    camera = three.PerspectiveCamera(20, width / height, 1, 10000);
    camera.position.z = 1800;

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xffffff);

    final light = three.DirectionalLight(0xffffff);
    light.position.set(0, 0, 1);
    scene.add(light);

    final shadowMaterial = three.MeshBasicMaterial({});
    final shadowGeo = three.PlaneGeometry(300, 300, 1, 1);

    three.Mesh shadowMesh;

    shadowMesh = three.Mesh(shadowGeo, shadowMaterial);
    shadowMesh.position.y = -250;
    shadowMesh.rotation.x = -three.Math.pi / 2;
    scene.add(shadowMesh);

    shadowMesh = three.Mesh(shadowGeo, shadowMaterial);
    shadowMesh.position.y = -250;
    shadowMesh.position.x = -400;
    shadowMesh.rotation.x = -three.Math.pi / 2;
    scene.add(shadowMesh);

    shadowMesh = three.Mesh(shadowGeo, shadowMaterial);
    shadowMesh.position.y = -250;
    shadowMesh.position.x = 400;
    shadowMesh.rotation.x = -three.Math.pi / 2;
    scene.add(shadowMesh);

    const radius = 200;

    final geometry1 = three.IcosahedronGeometry(radius, 1);

    final count = geometry1.attributes["position"].count;
    geometry1.setAttribute('color',
        three.Float32BufferAttribute( Float32Array(count * 3), 3));

    final geometry2 = geometry1.clone();
    final geometry3 = geometry1.clone();

    final color = three.Color(1, 1, 1);
    final positions1 = geometry1.attributes["position"];
    final positions2 = geometry2.attributes["position"];
    final positions3 = geometry3.attributes["position"];
    final colors1 = geometry1.attributes["color"];
    final colors2 = geometry2.attributes["color"];
    final colors3 = geometry3.attributes["color"];

    for (int i = 0; i < count; i++) {
      color.setHSL((positions1.getY(i) / radius + 1) / 2, 1.0, 0.5);
      colors1.setXYZ(i, color.r, color.g, color.b);

      color.setHSL(0, (positions2.getY(i) / radius + 1) / 2, 0.5);
      colors2.setXYZ(i, color.r, color.g, color.b);

      color.setRGB(1, 0.8 - (positions3.getY(i) / radius + 1) / 2, 0);
      colors3.setXYZ(i, color.r, color.g, color.b);
    }

    final material = three.MeshPhongMaterial({
      "color": 0xffffff,
      "flatShading": true,
      "vertexColors": true,
      "shininess": 0
    });

    final wireframeMaterial = three.MeshBasicMaterial(
        {"color": 0x000000, "wireframe": true, "transparent": true});

    three.Mesh mesh = three.Mesh(geometry1, material);
    three.Mesh wireframe = three.Mesh(geometry1, wireframeMaterial);
    mesh.add(wireframe);
    mesh.position.x = -400;
    mesh.rotation.x = -1.87;
    scene.add(mesh);

    mesh = three.Mesh(geometry2, material);
    wireframe = three.Mesh(geometry2, wireframeMaterial);
    mesh.add(wireframe);
    mesh.position.x = 400;
    scene.add(mesh);

    mesh = three.Mesh(geometry3, material);
    wireframe = three.Mesh(geometry3, wireframeMaterial);
    mesh.add(wireframe);
    scene.add(mesh);

    // scene.overrideMaterial = new three.MeshBasicMaterial();

    loaded = true;

    animate();
  }

  three.ImageElement generateTexture() {
    final pixels = Uint8Array(256 * 256 * 4);

    int x = 0, y = 0, l = pixels.length;

    for (int i = 0, j = 0; i < l; i += 4, j++) {
      x = j % 256;
      y = (x == 0) ? y + 1 : y;

      pixels[i] = 255;
      pixels[i + 1] = 255;
      pixels[i + 2] = 255;
      pixels[i + 3] = three.Math.floor(x ^ y);
    }

    return three.ImageElement(data: pixels, width: 256, height: 256);
  }

  void addMesh(geometry, material) {
    three.Mesh mesh = three.Mesh(geometry, material);

    mesh.position.x = (objects.length % 4) * 200 - 400;
    mesh.position.z = three.Math.floor(objects.length / 4) * 200 - 200;

    mesh.rotation.x = three.Math.random() * 200 - 100;
    mesh.rotation.y = three.Math.random() * 200 - 100;
    mesh.rotation.z = three.Math.random() * 200 - 100;

    objects.add(mesh);

    scene.add(mesh);
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }
    if (!loaded) {
      return;
    }
    render();

    // 30FPS
    Future.delayed(const Duration(milliseconds: 33), () {
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
