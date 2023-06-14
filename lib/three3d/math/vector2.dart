import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart';

class Vector2 extends Vector{
  String type = "Vector2";

  Vector2([num? x, num? y]) {
    this.x = x ?? 0;
    this.y = y ?? 0;
  }

  Vector2.fromJSON(List<double>? json) {
    if (json != null) {
      x = json[0];
      y = json[1];
    }
  }

  double get width => x.toDouble();
  set width(double value) => x = value;

  double get height => y.toDouble();
  set height(double value) => y = value;
  @override
  Vector2 set(num x, num y) {
    this.x = x;
    this.y = y;

    return this;
  }
  @override
  Vector2 setScalar(double scalar) {
    x = scalar;
    y = scalar;

    return this;
  }

  Vector2 setX(double x) {
    this.x = x;

    return this;
  }

  Vector2 setY(double y) {
    this.y = y;

    return this;
  }

  Vector2 setComponent(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      default:
        throw "index is out of range: $index";
    }

    return this;
  }
  @override
  num getComponent(int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        throw "index is out of range: $index";
    }
  }
  @override
  Vector2 clone() {
    return Vector2(x, y);
  }
  @override
  Vector2 copy(Vector v) {
    if(v is! Vector2) throw('v needs to be Vector2');
    x = v.x;
    y = v.y;

    return this;
  }
  @override
  Vector2 add(Vector a, {Vector? b}) {
    if(a is! Vector2) throw('v needs to be Vector2');
    if(b != null && b is! Vector2) throw('w needs to be Vector2 or null');
    if (b != null) {
      print(
          'THREE.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(a, b as Vector2);
    }

    x += a.x;
    y += a.y;

    return this;
  }
  @override
  Vector2 addScalar(num s) {
    x += s;
    y += s;

    return this;
  }

  Vector2 addVectors(Vector2 a, Vector2 b) {
    x = a.x + b.x;
    y = a.y + b.y;

    return this;
  }

  Vector2 addScaledVector(Vector2 v, double s) {
    x += v.x * s;
    y += v.y * s;

    return this;
  }
  @override
  Vector2 sub(Vector v, {Vector? w}) {
    if(v is! Vector2) throw('v needs to be Vector2');
    if(w != null && w is! Vector2) throw('w needs to be Vector2 or null');
    if (w != null) {
      print(
          'THREE.Vector2: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w as Vector2);
    }

    x -= v.x;
    y -= v.y;

    return this;
  }
  @override
  Vector2 subScalar(num s) {
    x -= s;
    y -= s;

    return this;
  }

  Vector2 subVectors(Vector2 a, Vector2 b) {
    x = a.x - b.x;
    y = a.y - b.y;

    return this;
  }

  Vector2 multiply(Vector2 v) {
    x *= v.x;
    y *= v.y;

    return this;
  }
  @override
  Vector2 multiplyScalar(num scalar) {
    x *= scalar;
    y *= scalar;

    return this;
  }

  Vector2 divide(Vector2 v) {
    x /= v.x;
    y /= v.y;

    return this;
  }
  @override
  Vector2 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }
  @override
  Vector2 applyMatrix3(Matrix3 m) {
    double x = this.x.toDouble();
    double y = this.y.toDouble();
    Float32Array e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6];
    this.y = e[1] * x + e[4] * y + e[7];

    return this;
  }

  Vector2 min(Vector2 v) {
    x = Math.min(x, v.x).toDouble();
    y = Math.min(y, v.y).toDouble();

    return this;
  }

  Vector2 max(Vector2 v) {
    x = Math.max(x, v.x);
    y = Math.max(y, v.y);

    return this;
  }

  Vector2 clamp(Vector2 min, Vector2 max) {
    // assumes min < max, componentwise

    x = Math.max(min.x, Math.min(max.x, x));
    y = Math.max(min.y, Math.min(max.y, y));

    return this;
  }
  @override
  Vector2 clampScalar(double minVal, double maxVal) {
    x = Math.max(minVal, Math.min(maxVal, x));
    y = Math.max(minVal, Math.min(maxVal, y));

    return this;
  }
  @override
  Vector2 clampLength(double min, double max) {
    double length = this.length();

    return divideScalar(length).multiplyScalar(Math.max(min, Math.min(max, length)));
  }
  @override
  Vector2 floor() {
    x = Math.floor(x).toDouble();
    y = Math.floor(y).toDouble();

    return this;
  }
  @override
  Vector2 ceil() {
    x = Math.ceil(x).toDouble();
    y = Math.ceil(y).toDouble();

    return this;
  }
  @override
  Vector2 round() {
    x = Math.round(x).toDouble();
    y = Math.round(y).toDouble();

    return this;
  }
  @override
  Vector2 roundToZero() {
    x = (x < 0) ? Math.ceil(x).toDouble() : Math.floor(x).toDouble();
    y = (y < 0) ? Math.ceil(y).toDouble() : Math.floor(y).toDouble();

    return this;
  }
  @override
  Vector2 negate() {
    x = -x;
    y = -y;

    return this;
  }

  num dot(Vector2 v) {
    return x * v.x + y * v.y;
  }

  num cross(Vector2 v) {
    return x * v.y - y * v.x;
  }
  @override
  num lengthSq() {
    return x * x + y * y;
  }
  @override
  double length() {
    return Math.sqrt(x * x + y * y);
  }
  @override
  num manhattanLength() {
    return (Math.abs(x) + Math.abs(y)).toDouble();
  }
  @override
  Vector2 normalize() {
    return divideScalar(length());
  }
  @override
  double angle() {
    // computes the angle in radians with respect to the positive x-axis
    double angle = Math.atan2(-y, -x) + Math.pi;
    return angle;
  }

  double distanceTo(Vector2 v) {
    return Math.sqrt(distanceToSquared(v));
  }

  num distanceToSquared(Vector2 v) {
    double dx = x - v.x.toDouble(), dy = y - v.y.toDouble();
    return dx * dx + dy * dy;
  }

  num manhattanDistanceTo(Vector2 v) {
    return (Math.abs(x - v.x) + Math.abs(y - v.y)).toDouble();
  }
  @override
  Vector2 setLength(double length) {
    return normalize().multiplyScalar(length);
  }

  Vector2 lerp(Vector2 v, double alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;

    return this;
  }

  Vector2 lerpVectors(Vector2 v1, Vector2 v2, double alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;

    return this;
  }
  @override
  bool equals(Vector v) {
    if(v is! Vector2) throw('v needs to be Vector2');
    return ((v.x == x) && (v.y == y));
  }
  @override
  Vector2 fromArray(List<num> array, [int offset = 0]) {
    x = array[offset].toDouble();
    y = array[offset + 1].toDouble();

    return this;
  }
  @override
  List<num> toArray([List<num>? array, int offset = 0]) {
    if (array == null) {
      array = List<num>.filled(offset + 2, 0);
    } else {
      while (array.length < offset + 2) {
        array.add(0.0);
      }
    }

    array[offset] = x;
    array[offset + 1] = y;
    return array;
  }
  @override
  List<num> toJSON() {
    return [x, y];
  }

  @override
  Vector2 fromBufferAttribute(BufferAttribute attribute, int index) {
    x = attribute.getX(index)!.toDouble();
    y = attribute.getY(index)!.toDouble();

    return this;
  }

  Vector2 rotateAround(Vector2 center, double angle) {
    double c = Math.cos(angle), s = Math.sin(angle);

    double x = this.x - center.x.toDouble();
    double y = this.y - center.y.toDouble();

    this.x = x * c - y * s + center.x;
    this.y = x * s + y * c + center.y;

    return this;
  }
  @override
  Vector2 random() {
    x = Math.random();
    y = Math.random();

    return this;
  }

  Vector2.fromJson(Map<String, double> json) {
    x = json['x']!;
    y = json['y']!;
  }
  @override
  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}
