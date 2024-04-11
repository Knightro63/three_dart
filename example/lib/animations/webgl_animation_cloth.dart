import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebglAnimationCloth extends StatefulWidget {
  WebglAnimationCloth({Key? key, required this.fileName}) : super(key: key);
  final String fileName;
  @override
  createState() => _State();
}

double restDistance = 25;

int xSegs = 10;
int ySegs = 10;

const drag = 1 - 0.03;
const damping = 0.03;
const mass = 0.1;

class _State extends State<WebglAnimationCloth> {
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

  int startTime = 0;

  bool verbose = false;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

  late three.Object3D model;

  late three.ParametricGeometry clothGeometry;

  Map<String, dynamic> params = {"enableWind": true, "showBall": true};

  List<int> pins = [];

  final windForce = three.Vector3(0, 0, 0);

  final ballPosition = three.Vector3(0, -45, 0);
  final double ballSize = 60; //40

  final tmpForce = three.Vector3();
  final diff = three.Vector3();

  late Cloth cloth;

  final gravity = three.Vector3(0, -981 * 1.4, 0).multiplyScalar(0.1);

  final timestep = 18 / 1000;
  final timestepSq = (18 / 1000) * (18 / 1000);

  late three.Mesh sphere;

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

  render() {
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
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

  void satisfyConstraints(p1, p2, double distance) {
    diff.subVectors(p2.position, p1.position);
    final currentDist = diff.length();
    if (currentDist == 0) return; // prevents division by 0
    final correction = diff.multiplyScalar(1 - distance / currentDist);
    final correctionHalf = correction.multiplyScalar(0.5);
    p1.position.add(correctionHalf);
    p2.position.sub(correctionHalf);
  }

  void simulate(now) {
    final windStrength = three.Math.cos(now / 7000) * 20 + 40;

    windForce.set(three.Math.sin(now / 2000), three.Math.cos(now / 3000),
        three.Math.sin(now / 1000));
    windForce.normalize();
    windForce.multiplyScalar(windStrength);

    // Aerodynamics forces

    final particles = cloth.particles;

    if (params["enableWind"]) {
      final normal = three.Vector3();
      final indices = clothGeometry.index!;
      final normals = clothGeometry.attributes["normal"];

      for (int i = 0, il = indices.count; i < il; i += 3) {
        for (int j = 0; j < 3; j++) {
          int indx = indices.getX(i + j)!.toInt();
          normal.fromBufferAttribute(normals, indx);
          tmpForce
              .copy(normal)
              .normalize()
              .multiplyScalar(normal.dot(windForce));
          particles[indx].addForce(tmpForce);
        }
      }
    }

    for (int i = 0, il = particles.length; i < il; i++) {
      final particle = particles[i];
      particle.addForce(gravity);

      particle.integrate(timestepSq);
    }

    // Start Constraints

    final constraints = cloth.constraints;
    final il = constraints.length;

    for (int i = 0; i < il; i++) {
      final constraint = constraints[i];
      satisfyConstraints(constraint[0], constraint[1], constraint[2]);
    }

    // Ball Constraints

    ballPosition.z = -three.Math.sin(now / 600) * 90; //+ 40;
    ballPosition.x = three.Math.cos(now / 400) * 70;

    if (params["showBall"]) {
      sphere.visible = true;

      for (int i = 0, il = particles.length; i < il; i++) {
        final particle = particles[i];
        final pos = particle.position;
        diff.subVectors(pos, ballPosition);
        if (diff.length() < ballSize) {
          // collided
          diff.normalize().multiplyScalar(ballSize);
          pos.copy(ballPosition).add(diff);
        }
      }
    } else {
      sphere.visible = false;
    }

    // Floor Constraints

    for (int i = 0, il = particles.length; i < il; i++) {
      final particle = particles[i];
      final pos = particle.position;
      if (pos.y < -250) {
        pos.y = -250;
      }
    }

    // Pin Constraints

    for (int i = 0, il = pins.length; i < il; i++) {
      final xy = pins[i];
      final p = particles[xy];
      p.position.copy(p.original);
      p.previous.copy(p.original);
    }
  }

  initPage() async {
    /* testing cloth simulation */

    cloth = Cloth(xSegs, ySegs);

    final pinsFormation = [];
    pins = [6];

    pinsFormation.add(pins);

    pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    pinsFormation.add(pins);

    pins = [0];
    pinsFormation.add(pins);

    pins = []; // cut the rope ;)
    pinsFormation.add(pins);

    pins = [0, cloth.w]; // classic 2 pins
    pinsFormation.add(pins);

    pins = pinsFormation[1];

    // scene

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xcce0ff);
    scene.fog = three.Fog(0xcce0ff, 500, 10000);

    // camera

    camera = three.PerspectiveCamera(30, width / height, 1, 10000);
    camera.position.set(1000, 50, 1500);

    // lights

    camera.lookAt(scene.position);

    scene.add(three.AmbientLight(0x666666, 1));

    final light = three.DirectionalLight(0xdfebff, 1);
    light.position.set(50, 200, 100);
    light.position.multiplyScalar(1.3);

    light.castShadow = true;

    light.shadow!.mapSize.width = 1024;
    light.shadow!.mapSize.height = 1024;

    const d = 300;

    light.shadow!.camera!.left = -d;
    light.shadow!.camera!.right = d;
    light.shadow!.camera!.top = d;
    light.shadow!.camera!.bottom = -d;

    light.shadow!.camera!.far = 1000;

    scene.add(light);

    // cloth material

    final loader = three.TextureLoader(null);
    final clothTexture = await loader.loadAsync(
        'assets/textures/patterns/circuit_pattern.png', null);
    // clothTexture.anisotropy = 16;

    final clothMaterial = three.MeshLambertMaterial(
        {"alphaMap": clothTexture, "side": three.DoubleSide, "alphaTest": 0.5});

    // cloth geometry

    clothGeometry =
        three.ParametricGeometry(clothFunction, cloth.w, cloth.h);

    // cloth mesh

    object = three.Mesh(clothGeometry, clothMaterial);
    object.position.set(0, 0, 0);
    object.castShadow = true;
    scene.add(object);

    // sphere

    final ballGeo = three.SphereGeometry(ballSize, 32, 16);
    final ballMaterial = three.MeshLambertMaterial();

    sphere = three.Mesh(ballGeo, ballMaterial);
    sphere.castShadow = true;
    sphere.receiveShadow = true;
    sphere.visible = false;
    scene.add(sphere);

    // ground

    final groundTexture = await loader.loadAsync('assets/textures/terrain/grasslight-big.jpg', null);
    loader.dispose();
    groundTexture.wrapS = groundTexture.wrapT = three.RepeatWrapping;
    groundTexture.repeat.set(25, 25);
    groundTexture.anisotropy = 16;
    groundTexture.encoding = three.sRGBEncoding;

    final groundMaterial = three.MeshLambertMaterial({"map": groundTexture});

    three.Mesh mesh = three.Mesh(three.PlaneGeometry(20000, 20000), groundMaterial);
    mesh.position.y = -250;
    mesh.rotation.x = -three.Math.pi / 2;
    mesh.receiveShadow = true;
    scene.add(mesh);

    // poles

    final poleGeo = three.BoxGeometry(5, 375, 5);
    final poleMat = three.MeshLambertMaterial();

    mesh = three.Mesh(poleGeo, poleMat);
    mesh.position.x = -125;
    mesh.position.y = -62;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = three.Mesh(poleGeo, poleMat);
    mesh.position.x = 125;
    mesh.position.y = -62;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = three.Mesh(three.BoxGeometry(255, 5, 5), poleMat);
    mesh.position.y = -250 + (750 / 2);
    mesh.position.x = 0;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    final gg = three.BoxGeometry(10, 10, 10);
    mesh = three.Mesh(gg, poleMat);
    mesh.position.y = -250;
    mesh.position.x = 125;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    mesh = three.Mesh(gg, poleMat);
    mesh.position.y = -250;
    mesh.position.x = -125;
    mesh.receiveShadow = true;
    mesh.castShadow = true;
    scene.add(mesh);

    loaded = true;
    startTime = DateTime.now().millisecondsSinceEpoch;

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

    //final delta = clock.getDelta();

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    simulate(currentTime - startTime);

    final p = cloth.particles;

    for (int i = 0, il = p.length; i < il; i++) {
      final v = p[i].position;
      clothGeometry.attributes["position"].setXYZ(i, v.x, v.y, v.z);
    }

    clothGeometry.attributes["position"].needsUpdate = true;
    clothGeometry.computeVertexNormals();
    sphere.position.copy(ballPosition);

    render();

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
                    }
                  )
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Particle {
  late three.Vector3 position;
  late three.Vector3 previous;
  late three.Vector3 original;
  late three.Vector3 a;

  dynamic mass;
  late double invMass;

  late three.Vector3 tmp;
  late three.Vector3 tmp2;

  Particle(x, y, z, mass) {
    position = three.Vector3();
    previous = three.Vector3();
    original = three.Vector3();
    a = three.Vector3(0, 0, 0); // acceleration
    this.mass = mass;
    invMass = 1 / mass;
    tmp = three.Vector3();
    tmp2 = three.Vector3();

    // init

    clothFunction(x, y, position); // position
    clothFunction(x, y, previous); // previous
    clothFunction(x, y, original);
  }

  // Force -> Acceleration

  void addForce(force) {
    a.add(tmp2.copy(force).multiplyScalar(invMass));
  }

  // Performs Verlet integration

  void integrate(timesq) {
    final newPos = tmp.subVectors(position, previous);
    newPos.multiplyScalar(drag).add(position);
    newPos.add(a.multiplyScalar(timesq));

    tmp = previous;
    previous = position;
    position = newPos;

    a.set(0, 0, 0);
  }
}

class Cloth {
  late int w;
  late int h;

  late List<Particle> particles;
  late List<dynamic> constraints;

  Cloth([int w = 10, int h = 10]) {
    this.w = w;
    this.h = h;

    List<Particle> particles = [];
    List<dynamic> constraints = [];

    // Create particles

    for (int v = 0; v <= h; v++) {
      for (int u = 0; u <= w; u++) {
        particles.add(Particle(u / w, v / h, 0, mass));
      }
    }

    // Structural

    for (int v = 0; v < h; v++) {
      for (int u = 0; u < w; u++) {
        constraints.add(
            [particles[index(u, v)], particles[index(u, v + 1)], restDistance]);

        constraints.add(
            [particles[index(u, v)], particles[index(u + 1, v)], restDistance]);
      }
    }

    for (int u = w, v = 0; v < h; v++) {
      constraints.add(
          [particles[index(u, v)], particles[index(u, v + 1)], restDistance]);
    }

    for (int v = h, u = 0; u < w; u++) {
      constraints.add(
          [particles[index(u, v)], particles[index(u + 1, v)], restDistance]);
    }

    this.particles = particles;
    this.constraints = constraints;
  }

  int index(int u, int v) {
    return u + v * (w + 1);
  }
}

void clothFunction(num u, num v, three.Vector3 target) {
  double width = restDistance * xSegs;
  double height = restDistance * ySegs;

  double x = (u - 0.5) * width;
  double y = (v + 0.5) * height;
  double z = 0.0;

  target.set(x, y, z);
}
