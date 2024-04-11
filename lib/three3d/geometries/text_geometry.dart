import '../extras/index.dart';
import 'extrude_geometry.dart';

/// Text = 3D Text
///
/// parameters = {
///  font: <THREE.Font>, // font
///
///  size: <float>, // size of the text
///  height: <float>, // thickness to extrude text
///  curveSegments: <int>, // number of points on the curves
///
///  bevelEnabled: <bool>, // turn on bevel
///  bevelThickness: <float>, // how deep into text bevel goes
///  bevelSize: <float>, // how far from text outline (including bevelOffset) is bevel
///  bevelOffset: <float> // how far from text outline does bevel start
/// }
/// 
class TextGeometry extends ExtrudeGeometry {
  @override
  String type = "TextGeometry";

  TextGeometry.create(List<Shape> shapes, ExtrudeGeometryOptions options):super(shapes, options);

  factory TextGeometry(String text, TextGeometryOptions parameters) {
    Font? font = parameters.font;
    if (!(font != null && font.isFont)) {
      throw ('THREE.TextGeometry: font parameter is not an instance of THREE.Font.');
    }

    final shapes = font.generateShapes(text, size: parameters.size);

    // translate parameters to ExtrudeGeometry API

    // parameters["depth"] = parameters["height"] ?? 50;

    // defaults

    // if (parameters.bevelThickness == null) parameters["bevelThickness"] = 10;
    // if (parameters.bevelSize == null) parameters["bevelSize"] = 8;
    // if (parameters.bevelEnabled == null) parameters["bevelEnabled"] = false;

    TextGeometry textBufferGeometry = TextGeometry.create(shapes, parameters);

    return textBufferGeometry;
  }
}

class TextGeometryOptions extends ExtrudeGeometryOptions{
  TextGeometryOptions({
    this.size = 100,
    this.font,

    int curveSegments = 12,
    int steps = 1,
    num height = 100,
    bool bevelEnabled = false,
    num bevelThickness = 10,
    num bevelSize = 8,
    num bevelOffset = 0,
    Curve? extrudePath,
    int bevelSegments = 3,
  }):super(
    curveSegments: curveSegments,
    steps: steps,
    depth: height,
    bevelEnabled: bevelEnabled,
    bevelThickness: bevelThickness,
    bevelSize: bevelSize,
    bevelOffset: bevelOffset,
    extrudePath: extrudePath,
    bevelSegments: bevelSegments
  );
  
  final double size;
  final Font? font;
}