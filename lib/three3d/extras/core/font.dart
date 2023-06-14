import 'package:three_dart/three_dart.dart';

class Font {
  String type = 'Font';
  late FontData data;
  bool isFont = true;

  List<Shape> generateShapes(String text, {double size = 100}) {
    throw ("Font generateShapes need implement .... ");
  }

  List<ShapePath> createPaths(
      String text, double size, FontData data) {
    // var chars = Array.from ? Array.from( text ) : String( text ).split( '' ); // workaround for IE11, see #13988
    List<String> chars = text.split("");

    double scale = size / data.resolution;
    double lineHeight = (data.boundingBox.yMax! -
            data.boundingBox.yMin! +
            data.underlineThickness) *
        scale;

    List<ShapePath> paths = [];

    double offsetX = 0.0;
    double offsetY = 0.0;

    for (int i = 0; i < chars.length; i++) {
      String char = chars[i];

      if (char == '\n') {
        offsetX = 0;
        offsetY -= lineHeight;
      } else {
        CreatePathUtil ret = createPath(char, scale, offsetX, offsetY, data);
        offsetX += ret.offsetX;
        paths.add(ret.path!);
      }
    }

    return paths;
  }

  CreatePathUtil createPath(String char, double scale, double offsetX, double offsetY, FontData data){
    throw ("Font generateShapes need implement .... ");
  }
}

class CreatePathUtil{
  CreatePathUtil({
    this.path,
    required this.offsetX,
    this.offsetY,
    this.char
  });

  double offsetX;
  ShapePath? path;
  double? offsetY;
  String? char;
}
class CreatePathUtil2{
  CreatePathUtil2({
    required this.paths,
    required this.width,
    required this.height,
    required this.chars
  });

  double height;
  Map<String, CreatePathUtil> paths;
  double width;
  List<CreatePathUtil> chars;
}
class FontData{
  FontData(json){
    resolution = json["resolution"];
    boundingBox = BoundingBox(
      yMax: json["boundingBox"]["yMax"],
      yMin: json["boundingBox"]["yMin"]
    );
    underlineThickness = json["underlineThickness"];
    glyphs = json["glyphs"];
    font = json["font"];
    familyName = json['familyName'];
  }
  String? familyName;
  dynamic glyphs;
  dynamic font;
  late double resolution;
  late BoundingBox boundingBox;
  late double underlineThickness;
}

class BoundingBox{
  BoundingBox({
    this.yMin,
    this.xMin,
    this.xMax,
    this.yMax
  });
  double? yMax;
  double? yMin;
  double? xMax;
  double? xMin;
}