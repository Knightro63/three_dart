import 'package:three_dart/three3d/core/index.dart';
import 'math.dart';
import 'matrix3.dart';
import 'matrix4.dart';
import 'quaternion.dart';
import 'vector.dart';
import 'vector3.dart';

class Vector4 extends Vector{
  String type = "Vector4";
  late double z;
  late double w;

  Vector4([num? x, num? y, num? z, num? w]) {
    this.x = x?.toDouble() ?? 0;
    this.y = y?.toDouble() ?? 0;
    this.z = z?.toDouble() ?? 0;
    this.w = w?.toDouble() ?? 0;
  }

  Vector4.init({double x = 0, double y = 0, this.z = 0, this.w = 1}){
    this.x = x;
    this.y = y;
  }

  Vector4.fromJSON(List<double>? json) {
    if (json != null) {
      x = json[0];
      y = json[1];
      z = json[2];
      w = json[3];
    }
  }

  @override
  List<num> toList() {
    return [x, y, z, w];
  }

  get width => z;
  set width(value) => z = value;

  get height => w;
  set height(value) => w = value;

  @override
  Vector4 set(num x, num y, [num? z, num? w]) {
    z ??= this.z;
    w ??= this.w;

    this.x = x.toDouble();
    this.y = y.toDouble();
    this.z = z.toDouble();
    this.w = w.toDouble();

    return this;
  }

  @override
  Vector4 setScalar(double scalar) {
    x = scalar;
    y = scalar;
    z = scalar;
    w = scalar;

    return this;
  }

  Vector4 setX(double x) {
    this.x = x;

    return this;
  }

  Vector4 setY(double y) {
    this.y = y;

    return this;
  }

  Vector4 setZ(double z) {
    this.z = z;

    return this;
  }

  Vector4 setW(double w) {
    this.w = w;

    return this;
  }

  Vector4 setComponent(int index, double value) {
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
      case 3:
        w = value;
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
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return w;
      default:
        throw ('index is out of range: $index');
    }
  }

  @override
  Vector4 clone() {
    return Vector4(x, y, z, w);
  }
  @override
  Vector4 copy(Vector v) {
    x = v.x;
    y = v.y;
    if(v is Vector4){
      z = v.z;
      w = v.w;
    }
    else if (v is Vector3){
      z = v.z;
    }

    return this;
  }
  @override
  Vector4 add(Vector a, [Vector? b]) {
    if (b != null) {
      print(
          'THREE.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(a, b);
    }

    x += a.x;
    y += a.y;
    if(a is Vector4){
      z += a.z;
      w += a.w;
    }
    else if(a is Vector3){
      z += a.z;
    }

    return this;
  }
  @override
  Vector4 addScalar(num s) {
    x += s;
    y += s;
    z += s;
    w += s;

    return this;
  }

  Vector4 addVectors(Vector a, Vector b) {
    x = a.x + b.x;
    y = a.y + b.y;
    if(a is Vector4 && b is Vector4){
      z = a.z + b.z;
      w = a.w + b.w;
    }
    else if(a is Vector3 && b is Vector3){
      z = a.z + b.z;
    }
    else if(a is Vector4 && b is Vector3){
      z = a.z + b.z;
    }
    else if(a is Vector3 && b is Vector4){
      z = a.z + b.z;
    }
    return this;
  }
  @override
  Vector4 addScaledVector(Vector v, double s) {
    x += v.x * s;
    y += v.y * s;
    if(v is Vector3){
      z += v.z * s;
    }
    else if(v is Vector4){
      z += v.z * s;
      w += v.w * s;
    }

    return this;
  }
  @override
  Vector4 sub(Vector a, [Vector? b]) {
    if (b != null) {
      print(
          'THREE.Vector4: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(a, b);
    }

    x -= a.x;
    y -= a.y;
    if(a is Vector4){
      z -= a.z;
      w -= a.w;
    }
    else if(a is Vector3){
      z -= a.z;
    }

    return this;
  }
  @override
  Vector4 subScalar(num s) {
    x -= s;
    y -= s;
    z -= s;
    w -= s;

    return this;
  }

  Vector4 subVectors(Vector a, Vector b) {
    x = a.x - b.x;
    y = a.y - b.y;
    if(a is Vector4 && b is Vector4){
      z = a.z - b.z;
      w = a.w - b.w;
    }
    else if(a is Vector3 && b is Vector3){
      z = a.z - b.z;
    }
    else if(a is Vector4 && b is Vector3){
      z = a.z - b.z;
    }
    else if(a is Vector3 && b is Vector4){
      z = a.z - b.z;
    }

    return this;
  }

  // multiply( v, w ) {

  Vector4 multiply(Vector4 v) {
    // if ( w != null ) {
    // 	print( 'THREE.Vector4: .multiply() now only accepts one argument. Use .multiplyVectors( a, b ) instead.' );
    // 	return this.multiplyVectors( v, w );
    // }

    x *= v.x;
    y *= v.y;
    z *= v.z;
    w *= v.w;

    return this;
  }

  @override
  double distanceTo(Vector v) {
    return Math.sqrt(distanceToSquared(v));
  }
  @override
  double distanceToSquared(Vector v) {
    final dx = x - v.x; 
    final dy = y - v.y;
    double dz = z;
    if(v is Vector3){
      dz-= v.z;
    }
    else if(v is Vector4){
      dz-= v.z;
    }
    final distance = dx * dx + dy * dy + dz * dz;
    return distance;
  }
  @override
  Vector4 multiplyScalar(num scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
    w *= scalar;

    return this;
  }

  Vector4 applyMatrix4(Matrix4 m) {
    final x = this.x, y = this.y, z = this.z, w = this.w;
    final e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w;
    this.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w;
    this.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w;
    this.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w;

    return this;
  }
  @override
  Vector4 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }

  Vector4 setAxisAngleFromQuaternion(Quaternion q) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/index.htm

    // q is assumed to be normalized

    w = 2 * Math.acos(q.w);

    final s = Math.sqrt(1 - q.w * q.w);

    if (s < 0.0001) {
      x = 1;
      y = 0;
      z = 0;
    } else {
      x = q.x / s;
      y = q.y / s;
      z = q.z / s;
    }

    return this;
  }
  @override
  Vector4 applyMatrix3(Matrix3 m) {
    final x = this.x, y = this.y, z = this.z;
    final e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6] * z;
    this.y = e[1] * x + e[4] * y + e[7] * z;
    this.z = e[2] * x + e[5] * y + e[8] * z;

    return this;
  }
  Vector4 setAxisAngleFromRotationMatrix(Matrix3 m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToAngle/index.htm

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    double angle, x, y, z; // variables for result
    double epsilon = 0.01, // margin to allow for rounding errors
        epsilon2 = 0.1; // margin to distinguish between 0 and 180 degrees

    final te = m.elements;
    double m11 = te[0];
    double m12 = te[4];
    double m13 = te[8];
    double m21 = te[1];
    double m22 = te[5];
    double m23 = te[9];
    double m31 = te[2];
    double m32 = te[6];
    double m33 = te[10];

    if ((Math.abs(m12 - m21) < epsilon) &&
        (Math.abs(m13 - m31) < epsilon) &&
        (Math.abs(m23 - m32) < epsilon)) {
      // singularity found
      // first check for identity matrix which must have +1 for all terms
      // in leading diagonal and zero in other terms

      if ((Math.abs(m12 + m21) < epsilon2) &&
          (Math.abs(m13 + m31) < epsilon2) &&
          (Math.abs(m23 + m32) < epsilon2) &&
          (Math.abs(m11 + m22 + m33 - 3) < epsilon2)) {
        // this singularity is identity matrix so angle = 0

        set(1, 0, 0, 0);

        return this; // zero angle, arbitrary axis

      }

      // otherwise this singularity is angle = 180

      angle = Math.pi;

      final xx = (m11 + 1) / 2;
      final yy = (m22 + 1) / 2;
      final zz = (m33 + 1) / 2;
      final xy = (m12 + m21) / 4;
      final xz = (m13 + m31) / 4;
      final yz = (m23 + m32) / 4;

      if ((xx > yy) && (xx > zz)) {
        // m11 is the largest diagonal term

        if (xx < epsilon) {
          x = 0;
          y = 0.707106781;
          z = 0.707106781;
        } else {
          x = Math.sqrt(xx);
          y = xy / x;
          z = xz / x;
        }
      } else if (yy > zz) {
        // m22 is the largest diagonal term

        if (yy < epsilon) {
          x = 0.707106781;
          y = 0;
          z = 0.707106781;
        } else {
          y = Math.sqrt(yy);
          x = xy / y;
          z = yz / y;
        }
      } else {
        // m33 is the largest diagonal term so base result on this

        if (zz < epsilon) {
          x = 0.707106781;
          y = 0.707106781;
          z = 0;
        } else {
          z = Math.sqrt(zz);
          x = xz / z;
          y = yz / z;
        }
      }

      set(x, y, z, angle);

      return this; // return 180 deg rotation

    }

    // as we have reached here there are no singularities so we can handle normally

    double s = Math.sqrt((m32 - m23) * (m32 - m23) +
        (m13 - m31) * (m13 - m31) +
        (m21 - m12) * (m21 - m12)); // used to normalize

    if (Math.abs(s) < 0.001) s = 1;

    // prevent divide by zero, should not happen if matrix is orthogonal and should be
    // caught by singularity test above, but I've left it in just in case

    this.x = (m32 - m23) / s;
    this.y = (m13 - m31) / s;
    this.z = (m21 - m12) / s;
    w = Math.acos((m11 + m22 + m33 - 1) / 2);

    return this;
  }

  Vector4 min(Vector4 v) {
    x = Math.min(x, v.x);
    y = Math.min(y, v.y);
    z = Math.min(z, v.z);
    w = Math.min(w, v.w);

    return this;
  }

  Vector4 max(Vector4 v) {
    x = Math.max(x, v.x);
    y = Math.max(y, v.y);
    z = Math.max(z, v.z);
    w = Math.max(w, v.w);

    return this;
  }

  Vector4 clamp(Vector4 min, Vector4 max) {
    // assumes min < max, componentwise

    x = Math.max(min.x, Math.min(max.x, x));
    y = Math.max(min.y, Math.min(max.y, y));
    z = Math.max(min.z, Math.min(max.z, z));
    w = Math.max(min.w, Math.min(max.w, w));

    return this;
  }
  @override
  Vector4 clampScalar(double minVal, double maxVal) {
    x = Math.max(minVal, Math.min(maxVal, x));
    y = Math.max(minVal, Math.min(maxVal, y));
    z = Math.max(minVal, Math.min(maxVal, z));
    w = Math.max(minVal, Math.min(maxVal, w));

    return this;
  }
  @override
  Vector4 clampLength<T extends num>(T min, T max) {
    final length = this.length();

    return divideScalar(length)
        .multiplyScalar(Math.max(min, Math.min(max, length)));
  }
  @override
  Vector4 floor() {
    x = Math.floor(x).toDouble();
    y = Math.floor(y).toDouble();
    z = Math.floor(z).toDouble();
    w = Math.floor(w).toDouble();

    return this;
  }
  @override
  Vector4 ceil() {
    x = Math.ceil(x).toDouble();
    y = Math.ceil(y).toDouble();
    z = Math.ceil(z).toDouble();
    w = Math.ceil(w).toDouble();

    return this;
  }
  @override
  Vector4 round() {
    x = Math.round(x).toDouble();
    y = Math.round(y).toDouble();
    z = Math.round(z).toDouble();
    w = Math.round(w).toDouble();

    return this;
  }
  @override
  Vector4 roundToZero() {
    x = (x < 0) ? Math.ceil(x).toDouble() : Math.floor(x).toDouble();
    y = (y < 0) ? Math.ceil(y).toDouble() : Math.floor(y).toDouble();
    z = (z < 0) ? Math.ceil(z).toDouble() : Math.floor(z).toDouble();
    w = (w < 0) ? Math.ceil(w).toDouble() : Math.floor(w).toDouble();

    return this;
  }
  @override
  Vector4 negate() {
    x = -x;
    y = -y;
    z = -z;
    w = -w;

    return this;
  }
  @override
  double dot(Vector v) {
    double temp = x * v.x + y * v.y;
    if(v is Vector3){
      temp += z * v.z;
    }
    else if(v is Vector4){
      temp += z * v.z+ w * v.w;
    }
    return temp;
  }
  @override
  double lengthSq() {
    return x * x + y * y + z * z + w * w;
  }
  @override
  double length() {
    return Math.sqrt(x * x + y * y + z * z + w * w);
  }
  @override
  double manhattanLength() {
    return (Math.abs(x) + Math.abs(y) + Math.abs(z) + Math.abs(w)).toDouble();
  }
  @override
  Vector4 normalize() {
    return divideScalar(length());
  }
  @override
  Vector4 setLength(double length) {
    return normalize().multiplyScalar(length);
  }

  Vector4 lerp(Vector4 v, double alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;
    w += (v.w - w) * alpha;

    return this;
  }

  Vector4 lerpVectors(Vector4 v1, Vector4 v2, double alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;
    w = v1.w + (v2.w - v1.w) * alpha;

    return this;
  }
  @override
  bool equals(Vector v) {
    if(v is Vector3){
      return (v.x == x) && (v.y == y) && (v.z == z);
    }
    else if(v is Vector4){
      return (v.x == x) && (v.y == y) && (v.z == z) && (v.w == w);
    }
    
    return (v.x == x) && (v.y == y);
  }
  @override
  Vector4 fromArray(array, [int offset = 0]) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];
    w = array[offset + 3];

    return this;
  }
  @override
  List<num> toArray([List<num>? array, int offset = 0]) {
    if (array == null) {
      array = List<num>.filled(offset + 4, 0);
    } else {
      while (array.length < offset + 4) {
        array.add(0.0);
      }
    }

    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;
    array[offset + 3] = w;
    return array;
  }
  @override
  Vector4 fromBufferAttribute(BufferAttribute attribute, int index) {
    x = attribute.getX(index)!.toDouble();
    y = attribute.getY(index)!.toDouble();
    z = attribute.getZ(index)!.toDouble();
    w = (attribute.getW(index) ?? 0).toDouble();

    return this;
  }
  @override
  Vector4 random() {
    x = Math.random();
    y = Math.random();
    z = Math.random();
    w = Math.random();

    return this;
  }

  Vector4.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    z = json['z'];
    w = json['w'];
  }
  @override
  Map<String, dynamic> toJSON() {
    return {'x': x, 'y': y, 'z': z, 'w': w};
  }
}
