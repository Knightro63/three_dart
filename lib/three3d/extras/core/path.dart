import '../../math/index.dart';
import 'curve.dart';
import 'curve_path.dart';
import '../curves/cubic_bezier_curve.dart';
import '../curves/ellipse_curve.dart';
import '../curves/line_curve.dart';
import '../curves/quadratic_bezier_curve.dart';
import '../curves/spline_curve.dart';

class Path extends CurvePath {
  Path([points]) : super() {
    if (points != null) {
      setFromPoints(points);
    }
  }

  Path.fromJSON(Map<String,dynamic> json) : super.fromJSON(json) {
    currentPoint.fromArray(json["currentPoint"]);
  }

  Path setFromPoints(List<Vector2> points) {
    moveTo(points[0].x, points[0].y);

    for (int i = 1, l = points.length; i < l; i++) {
      lineTo(points[i].x, points[i].y);
    }

    return this;
  }

  Path moveTo(num x, num y) {
    currentPoint.set(x.toDouble(), y.toDouble());
    return this;
  }

  Path lineTo(num x, num y) {
    final curve = LineCurve(currentPoint.clone(), Vector2(x.toDouble(), y.toDouble()));
    curves.add(curve);
    currentPoint.set(x.toDouble(), y.toDouble());
    return this;
  }

  Path quadraticCurveTo(num aCPx, num aCPy, num aX, num aY) {
    final curve = QuadraticBezierCurve(
      currentPoint.clone(),
      Vector2(aCPx.toDouble(), aCPy.toDouble()), 
      Vector2(aX.toDouble(), aY.toDouble())
    );
    curves.add(curve);
    currentPoint.set(aX.toDouble(), aY.toDouble());

    return this;
  }

  Path bezierCurveTo(num aCP1x, num aCP1y, num aCP2x, num aCP2y, num aX, num aY) {
    final curve = CubicBezierCurve(
      currentPoint.clone(),
      Vector2(aCP1x.toDouble(), aCP1y.toDouble()),
      Vector2(aCP2x.toDouble(), aCP2y.toDouble()),
      Vector2(aX.toDouble(), aY.toDouble())
    );

    curves.add(curve);
    currentPoint.set(aX.toDouble(), aY.toDouble());
    return this;
  }

  Path splineThru(List<Vector2> pts /*Array of Vector*/) {
    final npts = [currentPoint.clone()];
    npts.addAll(pts);

    final curve = SplineCurve(npts);
    curves.add(curve);

    currentPoint.copy(pts[pts.length - 1]);

    return this;
  }

  Path arc(num aX, num aY, num aRadius, num aStartAngle,num  aEndAngle, [bool? aClockwise]) {
    final x0 = currentPoint.x;
    final y0 = currentPoint.y;

    absarc(aX + x0, aY + y0, aRadius, aStartAngle, aEndAngle, aClockwise);

    return this;
  }

  Path absarc(num aX, num aY, num aRadius, num aStartAngle, num aEndAngle, [bool? aClockwise]) {
    absellipse(
        aX, aY, aRadius, aRadius, aStartAngle, aEndAngle, aClockwise);

    return this;
  }

  Path ellipse(num aX, num aY, num xRadius, num yRadius, num aStartAngle, num aEndAngle, [bool? aClockwise, num? aRotation]) {
    final x0 = currentPoint.x;
    final y0 = currentPoint.y;

    absellipse(aX + x0, aY + y0, xRadius, yRadius, aStartAngle, aEndAngle,
        aClockwise, aRotation);

    return this;
  }

  Path absellipse(num aX, num aY, num xRadius, num yRadius, num aStartAngle, num aEndAngle, [bool? aClockwise, num? aRotation]) {
    final curve = EllipseCurve(aX, aY, xRadius, yRadius, aStartAngle,
        aEndAngle, aClockwise, aRotation);

    if (curves.isNotEmpty) {
      // if a previous curve is present, attempt to join
      final firstPoint = curve.getPoint(0);

      if (firstPoint != null && !firstPoint.equals(currentPoint)) {
        lineTo(firstPoint.x, firstPoint.y);
      }
    }

    curves.add(curve);

    final lastPoint = curve.getPoint(1);
    if(lastPoint != null){
      currentPoint.copy(lastPoint);
    }

    return this;
  }

  @override
  Path copy(Curve source){
    assert(source is Path);
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
  Path fromJSON(Map<String,dynamic> json) {
    super.fromJSON(json);

    currentPoint.fromArray(json['currentPoint']);
    return this;
  }
}
