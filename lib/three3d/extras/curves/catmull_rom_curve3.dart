import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/math/index.dart';

/// Centripetal CatmullRom Curve - which is useful for avoiding
/// cusps and self-intersections in non-uniform catmull rom curves.
/// http://www.cemyuksel.com/research/catmullrom_param/catmullrom.pdf
///
/// curve.type accepts centripetal(default), chordal and catmullrom
/// curve.tension is used for catmullrom which defaults to 0.5

/*
Based on an optimized c++ solution in
 - http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections/
 - http://ideone.com/NoEbVM

This CubicPoly class could be used for reusing some variables and calculations,
but for three.js curve use, it could be possible inlined and flatten into a single function call
which can be placed in CurveUtils.
*/

class CubicPoly {
  num c0 = 0, c1 = 0, c2 = 0, c3 = 0;

  CubicPoly();

  /*
	 * Compute coefficients for a cubic polynomial
	 *   p(s) = c0 + c1*s + c2*s^2 + c3*s^3
	 * such that
	 *   p(0) = x0, p(1) = x1
	 *  and
	 *   p'(0) = t0, p'(1) = t1.
	 */
  void init(x0, x1, t0, t1) {
    c0 = x0;
    c1 = t0;
    c2 = -3 * x0 + 3 * x1 - 2 * t0 - t1;
    c3 = 2 * x0 - 2 * x1 + t0 + t1;
  }

  void initCatmullRom(x0, x1, x2, x3, tension) {
    init(x1, x2, tension * (x2 - x0), tension * (x3 - x1));
  }

  void initNonuniformCatmullRom(x0, x1, x2, x3, dt0, dt1, dt2) {
    // compute tangents when parameterized in [t1,t2]
    double t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1;
    double t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2;

    // rescale tangents for parametrization in [0,1]
    t1 *= dt1;
    t2 *= dt1;

    init(x1, x2, t1, t2);
  }

  double calc(double t) {
    double t2 = t * t;
    double t3 = t2 * t;
    return c0 + c1 * t + c2 * t2 + c3 * t3;
  }
}

//

Vector3 tmp = Vector3();
CubicPoly px = CubicPoly(), py = CubicPoly(), pz = CubicPoly();

class CatmullRomCurve3 extends Curve { 
  late bool closed;
  late String curveType;
  late num tension;

  CatmullRomCurve3({
    points,
    this.closed = false, 
    this.curveType = 'centripetal', 
    this.tension = 0.5
  }):super(){
    this.points = points ?? [];
    type = 'CatmullRomCurve3';
    isCatmullRomCurve3 = true;
  }

  @override
  Vector getPoint(num t, [Vector? optionalTarget]) {
    Vector3 point = (optionalTarget as Vector3?) ?? Vector3();

    List<Vector3> points = this.points as List<Vector3>;
    int l = points.length;

    double p = (l - (closed ? 0 : 1)) * t.toDouble();
    int intPoint = Math.floor(p);
    double weight = p - intPoint;

    if (closed) {
      intPoint += intPoint > 0 ? 0 : (Math.floor(Math.abs(intPoint) / l) + 1) * l;
    } else if (weight == 0 && intPoint == l - 1) {
      intPoint = l - 2;
      weight = 1;
    }

    Vector3 p0, p3; // 4 points (p1 & p2 defined below)

    if (closed || intPoint > 0) {
      p0 = points[(intPoint - 1) % l];
    } else {
      // extrapolate first point
      tmp.subVectors(points[0], points[1]).add(points[0]);
      p0 = tmp;
    }

    Vector3 p1 = points[intPoint % l];
    Vector3 p2 = points[(intPoint + 1) % l];

    if (closed || intPoint + 2 < l) {
      p3 = points[(intPoint + 2) % l];
    } else {
      // extrapolate last point
      tmp.subVectors(points[l - 1], points[l - 2]).add(points[l - 1]);
      p3 = tmp;
    }

    if (curveType == 'centripetal' || curveType == 'chordal') {
      // init Centripetal / Chordal Catmull-Rom
      double pow = curveType == 'chordal' ? 0.5 : 0.25;
      double dt0 = Math.pow(p0.distanceToSquared(p1), pow).toDouble();
      double dt1 = Math.pow(p1.distanceToSquared(p2), pow).toDouble();
      double dt2 = Math.pow(p2.distanceToSquared(p3), pow).toDouble();

      // safety check for repeated points
      if (dt1 < 1e-4) dt1 = 1.0;
      if (dt0 < 1e-4) dt0 = dt1;
      if (dt2 < 1e-4) dt2 = dt1;

      px.initNonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, dt0, dt1, dt2);
      py.initNonuniformCatmullRom(p0.y, p1.y, p2.y, p3.y, dt0, dt1, dt2);
      pz.initNonuniformCatmullRom(p0.z, p1.z, p2.z, p3.z, dt0, dt1, dt2);
    } else if (curveType == 'catmullrom') {
      px.initCatmullRom(p0.x, p1.x, p2.x, p3.x, tension);
      py.initCatmullRom(p0.y, p1.y, p2.y, p3.y, tension);
      pz.initCatmullRom(p0.z, p1.z, p2.z, p3.z, tension);
    }

    point.set(px.calc(weight), py.calc(weight), pz.calc(weight));

    return point;
  }

  @override
  CatmullRomCurve3 clone() {
    return CatmullRomCurve3().copy(this);
  }

  @override
  CatmullRomCurve3 copy(Curve source) {
    if(source is! CatmullRomCurve3) throw('source Curve must be CatmullRomCurve3');
    super.copy(source);

    points = [];

    for (int i = 0, l = source.points.length; i < l; i++) {
      Vector point = source.points[i];

      points.add(point.clone());
    }

    closed = source.closed;
    curveType = source.curveType;
    tension = source.tension;

    return this;
  }
}
