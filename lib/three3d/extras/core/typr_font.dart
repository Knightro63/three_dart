import 'package:three_dart/three_dart.dart';

class TYPRFont extends Font {
  TYPRFont(json) {
    data = FontData(json);
  }

  @override
  List<Shape> generateShapes(text, {double size = 100}) {
    List<Shape> shapes = [];
    List<ShapePath> paths = createPaths(text, size, data);

    for (int p = 0, pl = paths.length; p < pl; p++) {
      // Array.prototype.push.apply( shapes, paths[ p ].toShapes() );
      shapes.addAll(paths[p].toShapes(true, false));
    }

    return shapes;
  }

  CreatePathUtil2 generateShapes2(text, {int size = 100}) {
    return createPaths2(text, size, data);
  }

  // 同样文字路径不重复生成
  // 生成唯一文字路径
  // 记录 offset
  CreatePathUtil2 createPaths2(
      String text, num size, FontData data) {
    List<String> chars = text.split("");

    double scale = size / data.resolution;
    double lineHeight = (data.boundingBox.yMax! -
            data.boundingBox.yMin! +
            data.underlineThickness) *
        scale;

    // List<ShapePath> paths = [];

    Map<String, CreatePathUtil> paths = {};
    List<CreatePathUtil> result = [];

    num offsetX = 0.0;
    num offsetY = 0.0;

    num maxWidth = 0.0;

    for (int i = 0; i < chars.length; i++) {
      String char = chars[i];

      if (char == '\n') {
        offsetX = 0;
        offsetY -= lineHeight;
      } else {
        var charPath = paths[char];
        if (charPath == null) {
          CreatePathUtil ret = createPath(char, scale, 0.0, 0.0, data);
          paths[char] = ret;
          charPath = ret;
        }

        CreatePathUtil charData = CreatePathUtil(
          char: char,
          offsetX: offsetX.toDouble(),
          offsetY: offsetY.toDouble()
        );

        result.add(charData);

        offsetX += charPath.offsetX;
        // paths.add(ret["path"]);

        if (offsetX > maxWidth) {
          maxWidth = offsetX;
        }
      }
    }

    CreatePathUtil2 _data = CreatePathUtil2(
      paths: paths,
      chars: result,
      height: offsetY + lineHeight,
      width: maxWidth.toDouble()
    );

    return _data;
  }
  @override
  CreatePathUtil createPath(
      String char, double scale, double offsetX, double offsetY, FontData data) {
    List<int> _glyphs = List<int>.from(data.font.stringToGlyphs(char));

    var gid = _glyphs[0];
    var charPath = data.font.glyphToPath(gid);

    double preScale = (100000) / ((data.font.head["unitsPerEm"] ?? 2048) * 72);
    // var _preScale = 1;
    int ha = Math.round(data.font.hmtx["aWidth"][gid] * preScale);

    ShapePath path = ShapePath();

    double x = 0.1;
    double y = 0.1;
    double cpx, cpy, cpx1, cpy1, cpx2, cpy2;

    var cmds = charPath["cmds"];
    List<double> crds = List<double>.from(charPath["crds"].map((e) => e.toDouble()));

    // print(" charPath  before scale ....");
    // print(charPath);

    crds = crds.map((n) => Math.round(n * preScale).toDouble()).toList();

    // print(" charPath ha: ${ha} _preScale: ${_preScale} ");
    // print(cmds);
    // print(crds);

    int i = 0;
    int l = cmds.length;
    for (int j = 0; j < l; j++) {
      var action = cmds[j];

      switch (action) {
        case 'M': // moveTo
          x = crds[i++] * scale + offsetX;
          y = crds[i++] * scale + offsetY;

          path.moveTo(x, y);
          break;

        case 'L': // lineTo

          x = crds[i++] * scale + offsetX;
          y = crds[i++] * scale + offsetY;

          path.lineTo(x, y);

          break;

        case 'Q': // quadraticCurveTo

          cpx = crds[i++] * scale + offsetX;
          cpy = crds[i++] * scale + offsetY;
          cpx1 = crds[i++] * scale + offsetX;
          cpy1 = crds[i++] * scale + offsetY;

          path.quadraticCurveTo(cpx1, cpy1, cpx, cpy);

          break;

        case 'B':
        case 'C': // bezierCurveTo

          cpx = crds[i++] * scale + offsetX;
          cpy = crds[i++] * scale + offsetY;
          cpx1 = crds[i++] * scale + offsetX;
          cpy1 = crds[i++] * scale + offsetY;
          cpx2 = crds[i++] * scale + offsetX;
          cpy2 = crds[i++] * scale + offsetY;

          path.bezierCurveTo(cpx, cpy, cpx1, cpy1, cpx2, cpy2);

          break;
      }
    }

    return CreatePathUtil(
      offsetX: ha * scale.toDouble(),
      path: path
    );//{"offsetX": ha * scale, "path": path};
  }

  dispose() {}
}
