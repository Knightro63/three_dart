import 'math.dart';
import 'box3.dart';
import 'matrix4.dart';
import 'plane.dart';
import 'vector3.dart';

class Sphere {
  late Vector3 center;
  late double radius;

  final _box = Box3();
  final _v1 = Vector3();
  final _toFarthestPoint = Vector3();
  final _toPoint = Vector3();

  Sphere([Vector3? center, double? radius]) {
    this.center = center ?? Vector3();
    this.radius = radius ?? -1;
  }

  List<num> toList() {
    final data = center.toList();
    data.add(radius);
    return data;
  }

  Sphere set(Vector3 center, double radius) {
    this.center.copy(center);
    this.radius = radius;

    return this;
  }

  Sphere setFromPoints(List<Vector3> points, [Vector3? optionalCenter]) {
    final center = this.center;

    if (optionalCenter != null) {
      center.copy(optionalCenter);
    } else {
      _box.setFromPoints(points).getCenter(center);
    }

    num maxRadiusSq = 0.0;

    for (int i = 0, il = points.length; i < il; i++) {
      maxRadiusSq = Math.max(maxRadiusSq, center.distanceToSquared(points[i]));
    }

    radius = Math.sqrt(maxRadiusSq);

    return this;
  }

  Sphere clone() {
    return Sphere(null, null).copy(this);
  }

  Sphere copy(Sphere sphere) {
    center.copy(sphere.center);
    radius = sphere.radius;

    return this;
  }

  bool isEmpty() {
    return (radius < 0);
  }

  Sphere makeEmpty() {
    center.set(0, 0, 0);
    radius = -1;

    return this;
  }

  bool containsPoint(Vector3 point) {
    return (point.distanceToSquared(center) <= (radius * radius));
  }

  double distanceToPoint(Vector3 point) {
    return (point.distanceTo(center) - radius);
  }

  bool intersectsSphere(Sphere sphere) {
    final radiusSum = radius + sphere.radius;

    return sphere.center.distanceToSquared(center) <= (radiusSum * radiusSum);
  }

  bool intersectsBox(Box3 box) {
    return box.intersectsSphere(this);
  }

  bool intersectsPlane(Plane plane) {
    return Math.abs(plane.distanceToPoint(center)) <= radius;
  }

  Vector3 clampPoint(Vector3 point, Vector3 target) {
    final deltaLengthSq = center.distanceToSquared(point);

    target.copy(point);

    if (deltaLengthSq > (radius * radius)) {
      target.sub(center).normalize();
      target.multiplyScalar(radius).add(center);
    }

    return target;
  }

  Box3 getBoundingBox(Box3 target) {
    if (isEmpty()) {
      // Empty sphere produces empty bounding box
      target.makeEmpty();
      return target;
    }

    target.set(center, center);
    target.expandByScalar(radius);

    return target;
  }

  Sphere applyMatrix4(Matrix4 matrix) {
    center.applyMatrix4(matrix);

    radius = radius * matrix.getMaxScaleOnAxis();

    return this;
  }

  Sphere translate(Vector3 offset) {
    center.add(offset);

    return this;
  }

  Sphere expandByPoint(Vector3 point) {
    // from https://github.com/juj/MathGeoLib/blob/2940b99b99cfe575dd45103ef20f4019dee15b54/src/Geometry/Sphere.cpp#L649-L671

    _toPoint.subVectors(point, center);

    final lengthSq = _toPoint.lengthSq();

    if (lengthSq > (radius * radius)) {
      final length = Math.sqrt(lengthSq);
      final missingRadiusHalf = (length - radius) * 0.5;

      // Nudge this sphere towards the target point. Add half the missing distance to radius,
      // and the other half to position. This gives a tighter enclosure, instead of if
      // the whole missing distance were just added to radius.

      center.add(_toPoint.multiplyScalar(missingRadiusHalf / length));
      radius += missingRadiusHalf;
    }

    return this;
  }

  Sphere union(Sphere sphere) {
    // from https://github.com/juj/MathGeoLib/blob/2940b99b99cfe575dd45103ef20f4019dee15b54/src/Geometry/Sphere.cpp#L759-L769

    // To enclose another sphere into this sphere, we only need to enclose two points:
    // 1) Enclose the farthest point on the other sphere into this sphere.
    // 2) Enclose the opposite point of the farthest point into this sphere.

    if (center.equals(sphere.center) == true) {
      _toFarthestPoint.set(0, 0, 1).multiplyScalar(sphere.radius);
    } else {
      _toFarthestPoint
          .subVectors(sphere.center, center)
          .normalize()
          .multiplyScalar(sphere.radius);
    }

    expandByPoint(_v1.copy(sphere.center).add(_toFarthestPoint));
    expandByPoint(_v1.copy(sphere.center).sub(_toFarthestPoint));

    return this;
  }

  bool equals(Sphere sphere) {
    return sphere.center.equals(center) && (sphere.radius == radius);
  }
}
