import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class Path extends CurvePath {
  Path(points) : super() {
    type = 'Path';
    if (points != null) {
      setFromPoints(points);
    }
  }

  Path.fromJSON(json) : super.fromJSON(json) {
    type = 'Path';
    currentPoint.fromArray(json["currentPoint"]);
  }

  Path setFromPoints(List<Vector> points) {
    moveTo(points[0].x, points[0].y);

    for (int i = 1, l = points.length; i < l; i++) {
      lineTo(points[i].x, points[i].y);
    }

    return this;
  }

  Path moveTo(num x, num y) {
    currentPoint.set(x.toDouble(),
        y.toDouble()); // TODO consider referencing vectors instead of copying?
    return this;
  }

  Path lineTo(num x, num y) {
    LineCurve curve =
        LineCurve(currentPoint.clone(), Vector2(x.toDouble(), y.toDouble()));
    curves.add(curve);

    currentPoint.set(x.toDouble(), y.toDouble());

    return this;
  }

  Path quadraticCurveTo(num aCPx, num aCPy, num aX, num aY) {
    QuadraticBezierCurve curve = QuadraticBezierCurve(
        currentPoint.clone(),
        Vector2(aCPx.toDouble(), aCPy.toDouble()),
        Vector2(aX.toDouble(), aY.toDouble()));

    curves.add(curve);

    currentPoint.set(aX.toDouble(), aY.toDouble());

    return this;
  }

  Path bezierCurveTo(num aCP1x, num aCP1y, num aCP2x, num aCP2y, num aX, num aY) {
    CubicBezierCurve curve = CubicBezierCurve(
        currentPoint.clone(),
        Vector2(aCP1x.toDouble(), aCP1y.toDouble()),
        Vector2(aCP2x.toDouble(), aCP2y.toDouble()),
        Vector2(aX.toDouble(), aY.toDouble()));

    curves.add(curve);

    currentPoint.set(aX.toDouble(), aY.toDouble());

    return this;
  }

  Path splineThru(List<Vector2> pts /*Array of Vector*/) {
    List<Vector2> npts = [currentPoint.clone()];
    npts.addAll(pts);

    SplineCurve curve = SplineCurve(npts);
    curves.add(curve);

    currentPoint.copy(pts[pts.length - 1]);

    return this;
  }

  Path arc([
    double aX = 0,
    double aY = 0, 
    double aRadius = 1,     
    double aStartAngle = 0,
    double aEndAngle =2*Math.pi,
    bool aClockwise = false
  ]) {
    double x0 = currentPoint.x.toDouble();
    double y0 = currentPoint.y.toDouble();

    absarc(aX + x0, aY + y0, aRadius, aStartAngle, aEndAngle, aClockwise);

    return this;
  }

  Path absarc([
    double aX = 0,
    double aY = 0, 
    double aRadius = 1,     
    double aStartAngle = 0,
    double aEndAngle =2*Math.pi,
    bool aClockwise = false
  ]) {
    absellipse(
        aX, aY, aRadius, aRadius, aStartAngle, aEndAngle, aClockwise);

    return this;
  }

  Path ellipse([
    double aX = 0,
    double aY = 0,
    double xRadius = 1,
    double yRadius = 1,
    double aStartAngle = 0,
    double aEndAngle =2*Math.pi,
    bool aClockwise = false,
    double aRotation = 0
  ]) {
    double x0 = currentPoint.x.toDouble();
    double y0 = currentPoint.y.toDouble();

    absellipse(aX + x0, aY + y0, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation);

    return this;
  }

  Path absellipse([
    double aX = 0,
    double aY = 0,
    double xRadius = 1,
    double yRadius = 1,
    double aStartAngle = 0,
    double aEndAngle =2*Math.pi,
    bool aClockwise = false,
    double aRotation = 0
  ]) {
    EllipseCurve curve = EllipseCurve(aX, aY, xRadius, yRadius, aStartAngle, aEndAngle,
        aClockwise, aRotation);
    if (curves.isNotEmpty) {
      // if a previous curve is present, attempt to join
      Vector2 firstPoint = curve.getPoint(0)! as Vector2;

      if (!firstPoint.equals(currentPoint)) {
        lineTo(firstPoint.x, firstPoint.y);
      }
    }

    curves.add(curve);

    Vector lastPoint = curve.getPoint(1)!;
    currentPoint.copy(lastPoint);

    return this;
  }

  @override
  Path clone() {
    return Path(points).copy(this);
  }
  @override
  Path copy(Curve source) {
    if(source is! Path) throw('source Curve must be Path');
    super.copy(source);

    currentPoint.copy(source.currentPoint);

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["currentPoint"] = currentPoint.toArray();

    return data;
  }

  @override
  Path fromJSON(json) {
    super.fromJSON(json);

    currentPoint.fromArray(json.currentPoint);

    return this;
  }
}
