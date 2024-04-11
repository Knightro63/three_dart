import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglLoaderSvg extends StatefulWidget {
  WebglLoaderSvg({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglLoaderSvg> {
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

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  final guiData = {
    "currentURL": 'assets/models/svg/tiger.svg',
    // "currentURL": 'assets/models/svg/energy.svg',
    // "currentURL": 'assets/models/svg/hexagon.svg',
    // "currentURL": 'assets/models/svg/lineJoinsAndCaps.svg',
    // "currentURL": 'assets/models/svg/multiple-css-classes.svg',
    // "currentURL": 'assets/models/svg/threejs.svg',
    // "currentURL": 'assets/models/svg/zero-radius.svg',
    "drawFillShapes": true,
    "drawStrokes": true,
    "fillShapesWireframe": false,
    "strokesWireframe": false
  };

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
    camera = three.PerspectiveCamera(50, width / height, 1, 1000);
    camera.position.set(0, 0, 200);

    loadSVG(guiData["currentURL"]);

    animate();
  }

  void loadSVG(url) {
    scene = three.Scene();
    scene.background = three.Color(0xb0b0b0);

    final helper = three.GridHelper(160, 10);
    helper.rotation.x = three.Math.pi / 2;
    scene.add(helper);

    three.SVGLoader loader = three.SVGLoader();

    loader.load(
      url, 
      (three.SVGData data){
        print(data);
        List<three.ShapePath> paths = data.paths;

        three.Group group = three.Group();
        group.scale.multiplyScalar(0.25);
        group.position.x = -70;
        group.position.y = 70;
        group.rotateZ(three.Math.pi);
        group.rotateY(three.Math.pi);
        //group.scale.y *= -1;

        for (int i = 0; i < paths.length; i++) {
          three.ShapePath path = paths[i];

          final fillColor = path.userData?["style"]["fill"];
          if (guiData["drawFillShapes"] == true &&
              fillColor != null &&
              fillColor != 'none') {
            three.MeshBasicMaterial material = three.MeshBasicMaterial({
              "color":
                  three.Color().setStyle(fillColor).convertSRGBToLinear(),
              "opacity": path.userData?["style"]["fillOpacity"],
              "transparent": true,
              "side": three.DoubleSide,
              "depthWrite": false,
              "wireframe": guiData["fillShapesWireframe"]
            });

            final shapes = three.SVGLoader.createShapes(path);

            for (int j = 0; j < shapes.length; j++) {
              final shape = shapes[j];

              three.ShapeGeometry geometry = three.ShapeGeometry([shape]);
              three.Mesh mesh = three.Mesh(geometry, material);

              group.add(mesh);
            }
          }

          final strokeColor = path.userData?["style"]["stroke"];

          if (guiData["drawStrokes"] == true &&
              strokeColor != null &&
              strokeColor != 'none') {
            three.MeshBasicMaterial material = three.MeshBasicMaterial({
              "color":
                  three.Color().setStyle(strokeColor).convertSRGBToLinear(),
              "opacity": path.userData?["style"]["strokeOpacity"],
              "transparent": true,
              "side": three.DoubleSide,
              "depthWrite": false,
              "wireframe": guiData["strokesWireframe"]
            });

            for (int j = 0, jl = path.subPaths.length; j < jl; j++) {
              three.Path subPath = path.subPaths[j];
              final geometry = three.SVGLoader.pointsToStroke(
                  subPath.getPoints(), path.userData?["style"]);

              if (geometry != null) {
                final mesh = three.Mesh(geometry, material);

                group.add(mesh);
              }
            }
          }
        }

        scene.add(group);

        render();
      }
    );
    loader.dispose();
  }

  void animate() {
    if (!mounted || disposed) {
      return;
    }

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
