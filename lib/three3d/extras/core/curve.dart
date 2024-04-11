import '../../math/index.dart';
import '../curves/line_curve.dart';
import 'shape.dart';

/// Extensible curve object.
///
/// Some common of curve methods:
/// .getPoint( t, optionalTarget ), .getTangent( t, optionalTarget )
/// .getPointAt( u, optionalTarget ), .getTangentAt( u, optionalTarget )
/// .getPoints(), .getSpacedPoints()
/// .getLength()
/// .updateArcLengths()
///
/// This following curves inherit from THREE.Curve:
///
/// -- 2D curves --
/// THREE.ArcCurve
/// THREE.CubicBezierCurve
/// THREE.EllipseCurve
/// THREE.LineCurve
/// THREE.QuadraticBezierCurve
/// THREE.SplineCurve
///
/// -- 3D curves --
/// THREE.CatmullRomCurve3
/// THREE.CubicBezierCurve3
/// THREE.LineCurve3
/// THREE.QuadraticBezierCurve3
///
/// A series of curves can be represented as a THREE.CurvePath.
///
///*/

class Curve {
  late num arcLengthDivisions;
  bool needsUpdate = false;

  List<num>? cacheArcLengths;
  List<num>? cacheLengths;

  bool autoClose = false;
  List<Curve> curves = [];
  late List<Vector> points;

  bool isEllipseCurve = false;
  bool isLineCurve3 = false;
  bool isLineCurve = false;
  bool isSplineCurve = false;
  bool isCubicBezierCurve = false;
  bool isQuadraticBezierCurve = false;

  Vector2 currentPoint = Vector2();

  late Vector v0;
  late Vector2 v1;
  late Vector2 v2;

  Map<String, dynamic> userData = {};

  Curve() {
    arcLengthDivisions = 200;
  }

  Curve.fromJSON(Map<String, dynamic> json) {
    arcLengthDivisions = json["arcLengthDivisions"];
    v1 = Vector2.fromJSON(json["v1"]);
    v2 = Vector2.fromJSON(json["v2"]);
  }

  static Curve castJSON(Map<String, dynamic> json) {
    String type = json["type"];

    if (type == "Shape") {
      return Shape.fromJSON(json);
    } else if (type == "Curve") {
      return Curve.fromJSON(json);
    } else if (type == "LineCurve") {
      return LineCurve.fromJSON(json);
    } else {
      throw " type: $type Curve.castJSON is not support yet... ";
    }
  }

  // Virtual base class method to overwrite and implement in subclasses
  //	- t [0 .. 1]

  Vector? getPoint(num t, [Vector? optionalTarget]) {
    print('THREE.Curve: .getPoint() not implemented.');
    return null;
  }

  // Get point at relative position in curve according to arc length
  // - u [0 .. 1]

  Vector? getPointAt(num u, [Vector? optionalTarget]) {
    final t = getUtoTmapping(u);
    return getPoint(t, optionalTarget);
  }

  // Get sequence of points using getPoint( t )

  List<Vector?> getPoints([num divisions = 5]) {
    final List<Vector?> points = [];

    for (int d = 0; d <= divisions; d++) {
      points.add(getPoint(d / divisions));
    }

    return points;
  }

  // Get sequence of points using getPointAt( u )

  List<Vector?> getSpacedPoints([num divisions = 5, num offset = 0]) {
    final List<Vector?> points = [];

    for (int d = 0; d <= divisions; d++) {
      points.add(getPointAt(d / divisions));
    }

    return points;
  }

  // Get total curve arc length

  num getLength() {
    final lengths = getLengths(null);
    return lengths[lengths.length - 1];
  }

  // Get list of cumulative segment lengths

  List getLengths(num? divisions) {
    divisions ??= arcLengthDivisions;

    if (cacheArcLengths != null &&
        (cacheArcLengths!.length == divisions + 1) &&
        !needsUpdate) {
      return cacheArcLengths!;
    }

    needsUpdate = false;

    List<num> cache = [];
    Vector? current;
    Vector last = getPoint(0)!;
    num sum = 0.0;

    cache.add(0);

    for (int p = 1; p <= divisions; p++) {
      current = getPoint(p / divisions);
      if(current != null){
        sum += current.distanceTo(last);
        cache.add(sum);
        last = current;
      }
    }

    cacheArcLengths = cache;

    return cache; // { sums: cache, sum: sum }; Sum is in the last element.
  }

  void updateArcLengths() {
    needsUpdate = true;
    getLengths(null);
  }

  // Given u ( 0 .. 1 ), get a t to find p. This gives you points which are equidistant

  double getUtoTmapping(num u, [num? distance]) {
    final arcLengths = getLengths(null);

    int i = 0;
    int il = arcLengths.length;

    num targetArcLength; // The targeted u distance value to get

    if (distance != null) {
      targetArcLength = distance;
    } else {
      targetArcLength = u * arcLengths[il - 1];
    }

    // binary search for the index with largest value smaller than target u distance

    int low = 0, high = il - 1;
    num comparison;

    while (low <= high) {
      i = Math.floor(low + (high - low) / 2)
          .toInt(); // less likely to overflow, though probably not issue here, JS doesn't really have integers, all numbers are floats

      comparison = arcLengths[i] - targetArcLength;

      if (comparison < 0) {
        low = i + 1;
      } else if (comparison > 0) {
        high = i - 1;
      } else {
        high = i;
        break;

        // DONE

      }
    }

    i = high;

    if (arcLengths[i] == targetArcLength) {
      return i / (il - 1);
    }

    // we could get finer grain at lengths, or use simple interpolation between two points

    final lengthBefore = arcLengths[i];
    final lengthAfter = arcLengths[i + 1];

    final segmentLength = lengthAfter - lengthBefore;

    // determine where we are between the 'before' and 'after' points

    final segmentFraction = (targetArcLength - lengthBefore) / segmentLength;

    // add that fractional amount to t

    final t = (i + segmentFraction) / (il - 1);

    return t;
  }

  // Returns a unit vector tangent at t
  // In case any sub curve does not implement its tangent derivation,
  // 2 points a small delta apart will be used to find its gradient
  // which seems to give a reasonable approximation

  Vector getTangent(num t, [Vector? optionalTarget]) {
    final delta = 0.0001;
    num t1 = t - delta;
    num t2 = t + delta;

    // Capping in case of danger

    if (t1 < 0) t1 = 0;
    if (t2 > 1) t2 = 1;

    final pt1 = getPoint(t1);
    final pt2 = getPoint(t2);

    final tangent = optionalTarget ??
      ((pt1.runtimeType == Vector2)?Vector2(): Vector3());

    if(pt2 != null && pt1 != null){
      tangent.copy(pt2).sub(pt1).normalize();
    }

    return tangent;
  }

  Vector getTangentAt(num u, [Vector? optionalTarget]) {
    final t = getUtoTmapping(u);
    return getTangent(t, optionalTarget);
  }

  FrenetFrames computeFrenetFrames(int segments, bool closed) {
    // see http://www.cs.indiana.edu/pub/techreports/TR425.pdf

    final normal = Vector3();

    final List<Vector3> tangents = [];
    final List<Vector3> normals = [];
    final List<Vector3> binormals = [];

    final vec = Vector3();
    final mat = Matrix4();

    // compute the tangent vectors for each segment on the curve

    for (int i = 0; i <= segments; i++) {
      final u = i / segments;

      tangents.add(
        getTangentAt(u, Vector3()) as Vector3
      );
      tangents[i].normalize();
    }

    // select an initial normal vector perpendicular to the first tangent vector,
    // and in the direction of the minimum tangent xyz component

    normals.add(Vector3());
    binormals.add(Vector3());
    double min = Math.maxValue;
    final tx = Math.abs(tangents[0].x).toDouble();
    final ty = Math.abs(tangents[0].y).toDouble();
    final tz = Math.abs(tangents[0].z).toDouble();

    if (tx <= min) {
      min = tx;
      normal.set(1, 0, 0);
    }

    if (ty <= min) {
      min = ty;
      normal.set(0, 1, 0);
    }

    if (tz <= min) {
      normal.set(0, 0, 1);
    }

    vec.crossVectors(tangents[0], normal).normalize();

    normals[0].crossVectors(tangents[0], vec);
    binormals[0].crossVectors(tangents[0], normals[0]);

    // compute the slowly-varying normal and binormal vectors for each segment on the curve

    for (int i = 1; i <= segments; i++) {
      normals.add(normals[i - 1].clone());

      binormals.add(binormals[i - 1].clone());

      vec.crossVectors(tangents[i - 1], tangents[i]);

      if (vec.length() > Math.epsilon) {
        vec.normalize();

        final theta = Math.acos(MathUtils.clamp(tangents[i - 1].dot(tangents[i]),
            -1, 1)); // clamp for floating pt errors

        normals[i].applyMatrix4(mat.makeRotationAxis(vec, theta));
      }

      binormals[i].crossVectors(tangents[i], normals[i]);
    }

    // if the curve is closed, postprocess the vectors so the first and last normal vectors are the same

    if (closed) {
      double theta =
          Math.acos(MathUtils.clamp(normals[0].dot(normals[segments]), -1, 1));
      theta /= segments;

      if (tangents[0].dot(vec.crossVectors(normals[0], normals[segments])) >
          0) {
        theta = -theta;
      }

      for (int i = 1; i <= segments; i++) {
        // twist a little...
        normals[i].applyMatrix4(mat.makeRotationAxis(tangents[i], theta * i));
        binormals[i].crossVectors(tangents[i], normals[i]);
      }
    }

    return FrenetFrames(tangents: tangents, normals: normals, binormals: binormals);
  }

  Curve clone() {
    return Curve().copy(this);
  }

  Curve copy(Curve source) {
    arcLengthDivisions = source.arcLengthDivisions;
    return this;
  }

   Map<String,dynamic> toJSON() {
    Map<String, dynamic> data = {
      "metadata": {"version": 4.5, "type": 'Curve', "generator": 'Curve.toJSON'}
    };

    data["arcLengthDivisions"] = arcLengthDivisions;
    data["type"] = runtimeType.toString();

    return data;
  }

  Curve fromJSON(Map<String,dynamic> json) {
    arcLengthDivisions = json['arcLengthDivisions'];

    return this;
  }
}

class FrenetFrames{
  FrenetFrames({
    this.tangents, 
    this.normals, 
    this.binormals
  });

  final List<Vector3>? tangents;
  final List<Vector3>? normals;
  final List<Vector3>? binormals;
}
