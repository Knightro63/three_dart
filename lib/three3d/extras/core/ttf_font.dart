import 'package:three_dart/three_dart.dart';

class TTFFont extends Font {
  TTFFont(json) {
    data = FontData(json);
  }

  @override
  List<Shape> generateShapes(String text, {double size = 100}) {
    List<Shape> shapes = [];
    List<ShapePath> paths = createPaths(text, size, data);
    for (int p = 0, pl = paths.length; p < pl; p++) {
      // Array.prototype.push.apply( shapes, paths[ p ].toShapes() );
      shapes.addAll(paths[p].toShapes(false, false));
    }

    return shapes;
  }

  @override
  CreatePathUtil createPath(
      String char, double scale, double offsetX, double offsetY, FontData data) {
    dynamic glyph = data.glyphs[char] ?? data.glyphs['?'];

    if (glyph == null) {
      print("three.Font: character $char does not exists in font family ${data.familyName}");
      // return null;
      glyph = data.glyphs["a"];
    }

    ShapePath path = ShapePath();

    double x = 0.1;
    double y = 0.1;
    double cpx, cpy, cpx1, cpy1, cpx2, cpy2;

    if (glyph["o"] != null) {
      var outline = glyph["_cachedOutline"];

      if (outline == null) {
        glyph["_cachedOutline"] = glyph["o"].split(' ');
        outline = glyph["_cachedOutline"];
      }

      print(" outline scale: $scale ");
      print(outline);

      for (int i = 0, l = outline.length; i < l;) {
        String action = outline[i];
        i = i + 1;

        switch (action) {
          case 'm': // moveTo
            x = int.parse(outline[i++]) * scale + offsetX;
            y = int.parse(outline[i++]) * scale + offsetY;

            path.moveTo(x, y);
            break;

          case 'l': // lineTo

            x = int.parse(outline[i++]) * scale + offsetX;
            y = int.parse(outline[i++]) * scale + offsetY;

            path.lineTo(x, y);

            break;

          case 'q': // quadraticCurveTo

            cpx = int.parse(outline[i++]) * scale + offsetX;
            cpy = int.parse(outline[i++]) * scale + offsetY;
            cpx1 = int.parse(outline[i++]) * scale + offsetX;
            cpy1 = int.parse(outline[i++]) * scale + offsetY;

            path.quadraticCurveTo(cpx1, cpy1, cpx, cpy);

            break;

          case 'b': // bezierCurveTo

            cpx = int.parse(outline[i++]) * scale + offsetX;
            cpy = int.parse(outline[i++]) * scale + offsetY;
            cpx1 = int.parse(outline[i++]) * scale + offsetX;
            cpy1 = int.parse(outline[i++]) * scale + offsetY;
            cpx2 = int.parse(outline[i++]) * scale + offsetX;
            cpy2 = int.parse(outline[i++]) * scale + offsetY;

            path.bezierCurveTo(cpx1, cpy1, cpx2, cpy2, cpx, cpy);

            break;
        }
      }
    }

    return CreatePathUtil(
      offsetX: glyph["ha"] * scale,
      path: path
    );//{"offsetX": glyph["ha"] * scale, "path": path};
  }

  dispose() {}
}
