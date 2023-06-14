import 'package:three_dart/three_dart.dart';

/// ************************************************************
///	Curved Path - a curve path is simply a array of connected
///  curves, but retains the api of a curve
///*************************************************************/

class CurvePath extends Curve {
  @override
  CurvePath() : super() {
    type = 'CurvePath';
    curves = [];
    autoClose = false; // Automatically closes the path
    type = 'CurvePath';
  }

  CurvePath.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    autoClose = json["autoClose"];
    type = 'CurvePath';
    curves = [];

    for (int i = 0, l = json["curves"].length; i < l; i++) {
      var curve = json["curves"][i];
      curves.add(Curve.castJSON(curve));
    }
  }

  void add(CurvePath curve) {
    curves.add(curve);
  }

  void closePath() {
    // Add a line curve if start and end of lines are not connected
    Vector2 startPoint = curves[0].getPoint(0)! as Vector2;
    Vector2 endPoint = curves[curves.length - 1].getPoint(1)! as Vector2;

    if (!startPoint.equals(endPoint)) {
      curves.add(LineCurve(endPoint, startPoint));
    }
  }

  // To get accurate point with reference to
  // entire path distance at time t,
  // following has to be done:

  // 1. Length of each sub path have to be known
  // 2. Locate and identify type of curve
  // 3. Get t for the curve
  // 4. Return curve.getPointAt(t')

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    double d = t * getLength().toDouble();
    List<num> curveLengths = getCurveLengths();
    int i = 0;

    // To think about boundaries points.

    while (i < curveLengths.length) {
      if (curveLengths[i] >= d) {
        double diff = curveLengths[i] - d;
        Curve curve = curves[i];

        num segmentLength = curve.getLength();
        int u = segmentLength == 0 ? 0 : 1 - diff ~/ segmentLength;

        return curve.getPointAt(u, optionalTarget);
      }

      i++;
    }

    return null;

    // loop where sum != 0, sum > d , sum+1 <d
  }

  // We cannot use the default three.Curve getPoint() with getLength() because in
  // three.Curve, getLength() depends on getPoint() but in three.CurvePath
  // getPoint() depends on getLength

  @override
  num getLength() {
    List<num> lens = getCurveLengths();
    return lens[lens.length - 1];
  }

  // cacheLengths must be recalculated.
  @override
  void updateArcLengths() {
    needsUpdate = true;
    cacheLengths = null;
    getCurveLengths();
  }

  // Compute lengths and cache them
  // We cannot overwrite getLengths() because UtoT mapping uses it.
  List<num> getCurveLengths() {
    // We use cache values if curves and cache array are same length

    if (cacheLengths != null && cacheLengths!.length == curves.length) {
      return cacheLengths!;
    }

    // Get length of sub-curve
    // Push sums into cached array

    List<num> lengths = [];
    num sums = 0.0;

    for (int i = 0, l = curves.length; i < l; i++) {
      sums += curves[i].getLength();
      lengths.add(sums);
    }

    cacheLengths = lengths;

    return lengths;
  }

  @override
  List<Vector> getSpacedPoints([int divisions = 40, num offset = 0.0]) {
    List<Vector> points = [];

    for (int i = 0; i <= divisions; i++) {
      double _offset = offset + i / divisions;
      if (_offset > 1.0) {
        _offset = _offset - 1.0;
      }

      points.add(getPoint(_offset)!);
    }

    if (autoClose) {
      points.add(points[0]);
    }

    return points;
  }

  @override
  List<Vector> getPoints([int divisions = 12]) {
    List<Vector> points = [];
    Vector? last;

    List<Curve> curves = this.curves;

    for (int i = 0; i < curves.length; i++) {
      Curve curve = curves[i];
      int resolution = (curve.isEllipseCurve)
          ? divisions * 2
          : ((curve is LineCurve || curve is LineCurve3))
              ? 1
              : (curve.isSplineCurve)
                  ? divisions * curve.points.length.toInt()
                  : divisions;

      List<Vector> pts = curve.getPoints(resolution);

      for (int j = 0; j < pts.length; j++) {
        Vector point = pts[j];

        if (last != null && last.equals(point)) {
          continue;
        } // ensures no consecutive points are duplicates

        points.add(point);
        last = point;
      }
    }

    if (autoClose && points.length > 1 && !points[points.length - 1].equals(points[0])) {
      points.add(points[0]);
    }

    return points;
  }

  @override
  CurvePath copy(Curve source) {
    if(source is! CurvePath) throw('source Curve must be CurvePath');
    super.copy(source);

    curves = [];

    for (int i = 0, l = source.curves.length; i < l; i++) {
      Curve curve = source.curves[i];

      curves.add(curve.clone());
    }

    autoClose = source.autoClose;

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["autoClose"] = autoClose;
    data["curves"] = [];

    for (int i = 0, l = curves.length; i < l; i++) {
      Curve curve = curves[i];
      data["curves"].add(curve.toJSON());
    }

    return data;
  }

  @override
  CurvePath fromJSON(json) {
    super.fromJSON(json);

    autoClose = json.autoClose;
    curves = [];

    for (int i = 0, l = json.curves.length; i < l; i++) {
      var curve = json.curves[i];

      throw (" CurvePath fromJSON todo ");
      // this.curves.add( new Curves[ curve.type ]().fromJSON( curve ) );
    }

    return this;
  }
}
