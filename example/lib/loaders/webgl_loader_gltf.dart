import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;
import 'package:three_dart_jsm/three_dart_jsm/loaders/gltf/gltf_parser.dart';

class WebglLoaderGltf extends StatefulWidget {
  WebglLoaderGltf({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglLoaderGltf> {
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
  //late three.TextureLoader textureLoader;
  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey = GlobalKey<three_jsm.DomLikeListenableState>();
  late three_jsm.OrbitControls controls;
  three.WebGLRenderTarget? renderTarget;

  dynamic sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three.loading = {};
    controls.clearListeners();
    three3dRender.dispose();
    print(" dispose finish ");
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
      "dpr": dpr,
      'precision': 'highp'
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
    renderer!.clear(true, true, true);
    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    _gl.flush();
    controls.update();
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
      "canvas": three3dRender.element,
      "alpha": true,
      "clearColor": 0xffffff,
      "clearAlpha": 0,
    };

    if(!kIsWeb){
      _options['logarithmicDepthBuffer'] = true;
    }

    renderer = three.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;

    renderer!.shadowMap.enabled = false;
    renderer!.alpha = true;
    renderer!.setClearColor(three.Color(0xffffff), 0);
    renderer!.autoClearDepth = true;
    renderer!.autoClearStencil = true;
    renderer!.autoClear = true;

    if (!kIsWeb) {
      final pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat,"samples": 4});
      renderTarget = three.WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget!.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget!);
    }
    else {
      renderTarget = null;
    }
  }

  void initScene() async{
    await initPage();
    initRenderer();
    animate();
  }

  initPage() async {
    scene = three.Scene();

    camera = three.PerspectiveCamera(45, width / height, 0.25, 20);
    camera.position.set( - 0, 0, 2.7 );
    camera.lookAt(scene.position);

    three_jsm.OrbitControls _controls = three_jsm.OrbitControls(camera, _globalKey);
    controls = _controls;

    three_jsm.RGBELoader _loader = three_jsm.RGBELoader();
    _loader.setPath('assets/textures/equirectangular/');
    _loader.dispose();
    final _hdrTexture = await _loader.loadAsync('royal_esplanade_1k.hdr');
    _hdrTexture.mapping = three.EquirectangularReflectionMapping;

    scene.background = _hdrTexture;
    scene.environment = _hdrTexture;

    scene.add( three.AmbientLight( 0xffffff ) );

    three_jsm.GLTFLoader loader = three_jsm.GLTFLoader()
        .setPath('assets/models/gltf/DamagedHelmet/glTF/');

    final GLTFData result = await loader.loadAsync('DamagedHelmet.gltf');
    loader.dispose();

    print(" gltf load sucess result: $result  ");

    object = result.scene;

    scene.add(object);
    //textureLoader = three.TextureLoader();
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

    render();

    Future.delayed(Duration(milliseconds: 40), () {
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
          return _build(context);
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
    return Container(
      color: Colors.black,
      child: three_jsm.DomLikeListenable(
        key: _globalKey,
        builder: (BuildContext context) {
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).canvasColor,
            child: Builder(builder: (BuildContext context) {
              if (kIsWeb) {
                return three3dRender.isInitialized
                    ? HtmlElementView(
                        viewType:
                            three3dRender.textureId!.toString())
                    : Container();
              } else {
                return three3dRender.isInitialized
                    ? Texture(textureId: three3dRender.textureId!)
                    : Container();
              }
            })
          );
        }),
    );
  }
}
