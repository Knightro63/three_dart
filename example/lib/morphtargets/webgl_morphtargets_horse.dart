import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebglMorphtargetsHorse extends StatefulWidget {
  WebglMorphtargetsHorse({Key? key, required this.fileName})
      : super(key: key);
  final String fileName;
  @override
  createState() => _State();
}

class _State extends State<WebglMorphtargetsHorse> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Object3D mesh;

  three.AnimationMixer? mixer;
  three.Clock clock = three.Clock();
  three_jsm.OrbitControls? controls;

  double dpr = 1.0;

  bool verbose = false;
  bool disposed = false;

  double radius = 600;
  num theta = 0;

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
    camera = three.PerspectiveCamera(50, width / height, 1, 10000);
    camera.position.y = 300;

    scene = three.Scene();
    scene.background = three.Color(0xf0f0f0);

    //

    final light1 = three.DirectionalLight(0xefefff, 1.5);
    light1.position.set(1, 1, 1).normalize();
    scene.add(light1);

    final light2 = three.DirectionalLight(0xffefef, 1.5);
    light2.position.set(-1, -1, -1).normalize();
    scene.add(light2);

    final loader = three_jsm.GLTFLoader();
    final gltf = await loader.loadAsync('assets/models/gltf/Horse.gltf');
    loader.dispose();

    mesh = gltf.scene.children[0];
    mesh.scale.set(1.5, 1.5, 1.5);
    scene.add(mesh);

    mixer = three.AnimationMixer(mesh);
    final idleAction = mixer!.clipAction(gltf.animations![0]);
    idleAction!.play();
    
    loaded = true;

    animate();
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

    theta += 0.1;

    camera.position.x =
        radius * three.Math.sin(three.MathUtils.degToRad(theta));
    camera.position.z =
        radius * three.Math.cos(three.MathUtils.degToRad(theta));

    camera.lookAt(three.Vector3(0, 150, 0));

    if (mixer != null) {
      final delta = clock.getDelta();

      mixer!.update(delta);
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
