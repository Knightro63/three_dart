import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart';

var _vector3 = Vector3(0, 0, 0);

class Vector3 extends Vector{
  final _quaternion = Quaternion();

  String type = "Vector3";
  num z = 0;

  Vector3([num? x, num? y, num? z]) {
    this.x = x ?? 0;
    this.y = y ?? 0;
    this.z = z ?? 0;
  }

  Vector3.fromJSON(List<double>? json) {
    if (json != null) {
      x = json[0];
      y = json[1];
      z = json[2];
    }
  }
  @override
  Vector3 set(num x, num y, [num? z]) {
    z ??= this.z; // sprite.scale.set(x,y)

    this.x = x;
    this.y = y;
    this.z = z;

    return this;
  }

  void setP(String p, double v) {
    if (p == "x") {
      x = v;
    } else if (p == "y") {
      y = v;
    } else if (p == "z") {
      z = v;
    } else {
      throw (" Vector3.setP $p is not support ");
    }
  }
  @override
  Vector3 setScalar(scalar) {
    x = scalar;
    y = scalar;
    z = scalar;

    return this;
  }

  Vector3 setX(double x) {
    this.x = x;

    return this;
  }

  Vector3 setY(double y) {
    this.y = y;

    return this;
  }

  Vector3 setZ(double z) {
    this.z = z;

    return this;
  }

  Vector3 setComponent(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      case 2:
        z = value;
        break;
      default:
        throw ('index is out of range: $index');
    }

    return this;
  }
  @override
  double getComponent(int index) {
    switch (index) {
      case 0:
        return x.toDouble();
      case 1:
        return y.toDouble();
      case 2:
        return z.toDouble();
      default:
        throw ('index is out of range: $index');
    }
  }
  @override
  Vector3 clone() {
    return Vector3(x, y, z);
  }

  @override
  Vector3 copy(Vector v) {
    // TODO
    if(v is! Vector3) throw('v needs to be Vector3');
    x = v.x;
    y = v.y;
    z = v.z;

    return this;
  }
  @override
  Vector3 add(Vector a, {Vector? b}) {
    if(a is! Vector3) throw('v needs to be Vector3');
    if(b != null && b is! Vector3) throw('w needs to be Vector3 or null');
    if (b != null) {
      print(
          'THREE.Vector3: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(a, b as Vector3);
    }

    x += a.x;
    y += a.y;
    z += a.z;

    return this;
  }
  @override
  Vector3 addScalar(num s) {
    x += s;
    y += s;
    z += s;

    return this;
  }

  Vector3 addVectors(Vector3 a, Vector3 b) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;

    return this;
  }

  Vector3 addScaledVector(Vector3 v, num s) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;

    return this;
  }
  @override
  Vector3 sub(Vector v, {Vector? w}) {
    if(v is! Vector3) throw('v needs to be Vector3');
    if(w != null && w is! Vector3) throw('w needs to be Vector3 or null');
    if (w != null) {
      print(
          'THREE.Vector3: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w as Vector3);
    }

    x -= v.x;
    y -= v.y;
    z -= v.z;

    return this;
  }
  @override
  Vector3 subScalar(num s) {
    x -= s;
    y -= s;
    z -= s;

    return this;
  }

  Vector3 subVectors(Vector3 a, Vector3 b) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;

    return this;
  }

  Vector3 multiply(Vector3 v) {
    x *= v.x;
    y *= v.y;
    z *= v.z;

    return this;
  }
  @override
  Vector3 multiplyScalar(num scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;

    return this;
  }

  Vector3 multiplyVectors(Vector3 a, Vector3 b) {
    x = a.x * b.x;
    y = a.y * b.y;
    z = a.z * b.z;

    return this;
  }

  Vector3 applyEuler(Euler? euler) {
    if (!(euler != null && euler.type == "Euler")) {
      print('three.Vector3: .applyEuler() now expects an Euler rotation rather than a Vector3 and order.');
    }

    return applyQuaternion(_quaternion.setFromEuler(euler!, false));
  }

  Vector3 applyAxisAngle(axis, angle) {
    return applyQuaternion(_quaternion.setFromAxisAngle(axis, angle));
  }
  @override
  Vector3 applyMatrix3(Matrix3 m) {
    num x = this.x, y = this.y, z = this.z;
    Float32Array e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6] * z;
    this.y = e[1] * x + e[4] * y + e[7] * z;
    this.z = e[2] * x + e[5] * y + e[8] * z;

    return this;
  }

  applyNormalMatrix(Matrix3 m) {
    return applyMatrix3(m).normalize();
  }

  Vector3 applyMatrix4(Matrix4 m) {
    Float32Array e = m.elements;

    num x = this.x;
    num y = this.y;
    num z = this.z;

    double w = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15]);

    this.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * w;
    this.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * w;
    this.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w;

    return this;
  }

  Vector3 applyQuaternion(Quaternion q) {
    num qx = q.x;
    num qy = q.y;
    num qz = q.z;
    num qw = q.w;

    // calculate quat * vector

    num ix = qw * x + qy * z - qz * y;
    num iy = qw * y + qz * x - qx * z;
    num iz = qw * z + qx * y - qy * x;
    num iw = -qx * x - qy * y - qz * z;

    // calculate result * inverse quat

    x = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    y = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    z = iz * qw + iw * -qz + ix * -qy - iy * -qx;

    return this;
  }


  Vector3 project(Camera camera) {
    return applyMatrix4(camera.matrixWorldInverse)
        .applyMatrix4(camera.projectionMatrix);
  }

  Vector3 unproject(Camera camera) {
    return applyMatrix4(camera.projectionMatrixInverse)
        .applyMatrix4(camera.matrixWorld);
  }

  Vector3 transformDirection(Matrix4 m) {
    // input: three.Matrix4 affine matrix
    // vector interpreted as a direction

    num x = this.x, y = this.y, z = this.z;
    Float32Array e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z;
    this.y = e[1] * x + e[5] * y + e[9] * z;
    this.z = e[2] * x + e[6] * y + e[10] * z;

    return normalize();
  }

  Vector3 divide(Vector3 v) {
    x /= v.x;
    y /= v.y;
    z /= v.z;

    return this;
  }
  @override
  Vector3 divideScalar(num scalar) {
    return multiplyScalar(1 / scalar);
  }

  Vector3 min(Vector3 v) {
    x = Math.min(x, v.x);
    y = Math.min(y, v.y);
    z = Math.min(z, v.z);

    return this;
  }

  Vector3 max(Vector3 v) {
    x = Math.max(x, v.x);
    y = Math.max(y, v.y);
    z = Math.max(z, v.z);

    return this;
  }

  Vector3 clamp(Vector3 min, Vector3 max) {
    // assumes min < max, componentwise

    x = Math.max(min.x, Math.min(max.x, x));
    y = Math.max(min.y, Math.min(max.y, y));
    z = Math.max(min.z, Math.min(max.z, z));

    return this;
  }
  @override
  Vector3 clampScalar(double minVal,double maxVal) {
    x = Math.max(minVal, Math.min(maxVal, x));
    y = Math.max(minVal, Math.min(maxVal, y));
    z = Math.max(minVal, Math.min(maxVal, z));

    return this;
  }
  @override
  Vector3 clampLength(double min, double max) {
    double length = this.length();

    return divideScalar(length).multiplyScalar(Math.max(min, Math.min(max, length)));
  }
  @override
  Vector3 floor() {
    x = Math.floor(x).toDouble();
    y = Math.floor(y).toDouble();
    z = Math.floor(z).toDouble();

    return this;
  }
  @override
  Vector3 ceil() {
    x = Math.ceil(x).toDouble();
    y = Math.ceil(y).toDouble();
    z = Math.ceil(z).toDouble();

    return this;
  }
  @override
  Vector3 round() {
    x = Math.round(x).toDouble();
    y = Math.round(y).toDouble();
    z = Math.round(z).toDouble();

    return this;
  }
  @override
  Vector3 roundToZero() {
    x = (x < 0) ? Math.ceil(x).toDouble() : Math.floor(x).toDouble();
    y = (y < 0) ? Math.ceil(y).toDouble() : Math.floor(y).toDouble();
    z = (z < 0) ? Math.ceil(z).toDouble() : Math.floor(z).toDouble();

    return this;
  }
  @override
  Vector3 negate() {
    x = -x;
    y = -y;
    z = -z;

    return this;
  }

  num dot(Vector3 v) {
    return x * v.x + y * v.y + z * v.z;
  }

  // TODO lengthSquared?
  @override
  num lengthSq() {
    return x * x + y * y + z * z;
  }
  @override
  double length() {
    return Math.sqrt(x * x + y * y + z * z);
  }
  @override
  num manhattanLength() {
    return Math.abs(x) + Math.abs(y) + Math.abs(z);
  }
  @override
  Vector3 normalize() {
    return divideScalar(length());
  }
  @override
  Vector3 setLength(num length) {
    return normalize().multiplyScalar(length);
  }

  Vector3 lerp(Vector3 v, num alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;

    return this;
  }

  Vector3 lerpVectors(Vector3 v1, Vector3 v2, num alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;

    return this;
  }

  Vector3 cross(Vector3 v, {Vector3? w}) {
    if (w != null) {
      print('three.Vector3: .cross() now only accepts one argument. Use .crossVectors( a, b ) instead.');
      return crossVectors(v, w);
    }

    return crossVectors(this, v);
  }

  Vector3 crossVectors(Vector3 a, Vector3 b) {
    num ax = a.x, ay = a.y, az = a.z;
    num bx = b.x, by = b.y, bz = b.z;

    x = ay * bz - az * by;
    y = az * bx - ax * bz;
    z = ax * by - ay * bx;

    return this;
  }

  Vector3 projectOnVector(Vector3 v) {
    double denominator = v.lengthSq().toDouble();

    if (denominator == 0) return set(0, 0, 0);

    double scalar = v.dot(this) / denominator;

    return copy(v).multiplyScalar(scalar);
  }

  Vector3 projectOnPlane(Vector3 planeNormal) {
    _vector3.copy(this).projectOnVector(planeNormal);

    return sub(_vector3);
  }

  Vector3 reflect(Vector3 normal) {
    // reflect incident vector off plane orthogonal to normal
    // normal is assumed to have unit length

    return sub(_vector3.copy(normal).multiplyScalar(2 * dot(normal)));
  }

  double angleTo(Vector3 v) {
    double denominator = Math.sqrt(lengthSq() * v.lengthSq());

    if (denominator == 0) return Math.pi / 2;

    double theta = dot(v) / denominator;

    // clamp, to handle numerical problems

    return Math.acos(MathUtils.clamp(theta, -1, 1));
  }

  double distanceTo(Vector3 v) {
    return Math.sqrt(distanceToSquared(v));
  }

  num distanceToSquared(Vector3 v) {
    final dx = x - v.x, dy = y - v.y, dz = z - v.z;
    final distance = dx * dx + dy * dy + dz * dz;
    return distance;
  }

  double manhattanDistanceTo(Vector3 v) {
    return Math.abs(x - v.x) + Math.abs(y - v.y) + Math.abs(z - v.z).toDouble();
  }

  Vector3 setFromSpherical(s) {
    return setFromSphericalCoords(s.radius, s.phi, s.theta);
  }

  Vector3 setFromSphericalCoords(num radius, num phi, num theta) {
    double sinPhiRadius = Math.sin(phi) * radius;

    x = sinPhiRadius * Math.sin(theta);
    y = Math.cos(phi) * radius;
    z = sinPhiRadius * Math.cos(theta);

    return this;
  }

  Vector3 setFromCylindrical(c) {
    return setFromCylindricalCoords(c.radius, c.theta, c.y);
  }

  Vector3 setFromCylindricalCoords(double radius, double theta, double y) {
    x = radius * Math.sin(theta);
    this.y = y;
    z = radius * Math.cos(theta);

    return this;
  }

  Vector3 setFromMatrixPosition(Matrix4 m) {
    Float32Array e = m.elements;

    x = e[12];
    y = e[13];
    z = e[14];

    return this;
  }

  Vector3 setFromMatrixScale(Matrix4 m) {
    double sx = setFromMatrixColumn(m, 0).length();
    double sy = setFromMatrixColumn(m, 1).length();
    double sz = setFromMatrixColumn(m, 2).length();

    x = sx;
    y = sy;
    z = sz;

    return this;
  }

  Vector3 setFromMatrixColumn(Matrix4 m, int index) {
    return fromArray(m.elements.toDartList(), index * 4);
  }

  Vector3 setFromMatrix3Column(Matrix3 m, int index) {
    return fromArray(m.elements.toDartList(), index * 3);
  }

  Vector3 setFromEuler(Euler e) {
    x = e.x;
    y = e.y;
    z = e.z;

    return this;
  }
  @override
  bool equals(Vector v) {
    if(v is! Vector3) throw('v needs to be Vector3');
    return ((v.x == x) && (v.y == y) && (v.z == z));
  }
  @override
  // array  list | native array
  Vector3 fromArray(List<num> array, [int offset = 0]) {
    x = array[offset].toDouble();
    y = array[offset + 1].toDouble();
    z = array[offset + 2].toDouble();

    return this;
  }
  @override
  List<num> toArray([List<num>? array, int offset = 0]) {
    if (array == null) {
      array = List<num>.filled(offset + 3, 0);
    } else {
      while (array.length < offset + 3) {
        array.add(0.0);
      }
    }

    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;

    return array;
  }
  @override
  Vector3 fromBufferAttribute(BufferAttribute attribute, int index) {
    x = attribute.getX(index)!.toDouble();
    y = attribute.getY(index)!.toDouble();
    z = attribute.getZ(index)!.toDouble();

    return this;
  }
  @override
  Vector3 random() {
    x = Math.random();
    y = Math.random();
    z = Math.random();

    return this;
  }

  Vector3 randomDirection() {
    // Derived from https://mathworld.wolfram.com/SpherePointPicking.html
    double u = (Math.random() - 0.5) * 2;
    double t = Math.random() * Math.pi * 2;
    double f = Math.sqrt(1 - u * u);

    x = f * Math.cos(t);
    y = f * Math.sin(t);
    z = u;

    return this;
  }
  @override
  List<num> toJSON() {
    return [x, y, z];
  }
}
