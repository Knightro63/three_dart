import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebglSkinningSimple extends StatefulWidget {
  WebglSkinningSimple({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglSkinningSimple> {
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
    camera = three.PerspectiveCamera(45, width / height, 1, 1000);
    camera.position.set(18, 6, 18);

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xa0a0a0);
    scene.fog = three.Fog(0xa0a0a0, 70, 100);

    clock = three.Clock();

    // ground

    final geometry = three.PlaneGeometry(500, 500);
    final material =
        three.MeshPhongMaterial({"color": 0x999999, "depthWrite": false});

    final ground = three.Mesh(geometry, material);
    ground.position.set(0, -5, 0);
    ground.rotation.x = -three.Math.pi / 2;
    ground.receiveShadow = true;
    scene.add(ground);

    final grid = three.GridHelper(500, 100, 0x000000, 0x000000);
    grid.position.y = -5;
    grid.material.opacity = 0.2;
    grid.material.transparent = true;
    scene.add(grid);

    // lights

    final hemiLight = three.HemisphereLight(0xffffff, 0x444444, 0.6);
    hemiLight.position.set(0, 200, 0);
    scene.add(hemiLight);

    final dirLight = three.DirectionalLight(0xffffff, 0.8);
    dirLight.position.set(0, 20, 10);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.top = 18;
    dirLight.shadow!.camera!.bottom = -10;
    dirLight.shadow!.camera!.left = -12;
    dirLight.shadow!.camera!.right = 12;
    scene.add(dirLight);

    camera.lookAt(scene.position);

    final loader = three_jsm.GLTFLoader(null).setPath('assets/models/gltf/');

    // final result = await loader.loadAsync( 'Parrot.gltf');
    final result = await loader.loadAsync('SimpleSkinning.gltf');
    loader.dispose();

    print(" gltf load sucess result: $result  ");

    object = result.scene;

    object.traverse((child) {
      if (child is SkinnedMesh) child.castShadow = true;
    });

    final skeleton = three.SkeletonHelper(object);
    skeleton.visible = true;
    scene.add(skeleton);

    mixer = three.AnimationMixer(object);

    final clip = result.animations?[0];
    if (clip != null) {
      final action = mixer!.clipAction(clip);
      action?.play();
    }

    scene.add(object);

    // scene.overrideMaterial = new three.MeshBasicMaterial();

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

    final delta = clock.getDelta();

    mixer?.update(delta);

    render();

    Future.delayed(const Duration(milliseconds: 17), () {
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
