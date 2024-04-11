import 'package:three_dart/three3d/core/index.dart';
import 'matrix3.dart';

abstract class Vector {
  double x;
  double y;
  Vector([this.x = 0,this.y = 0]);

  Vector set(num x, num y);
  bool equals(Vector v);
  Vector copy(Vector v);
  Vector sub(Vector a, [Vector? b]);
  Vector add(Vector a, [Vector? b]);
  Vector setScalar(double scalar);

  num getComponent(int index);
  Vector clone();
  Vector addScaledVector(Vector v, double s);
  Vector addScalar(num s);
  Vector subScalar(num s);
  num dot(Vector v);
  Vector multiplyScalar(num scalar);
  Vector divideScalar(double scalar);
  Vector applyMatrix3(Matrix3 m);
  Vector clampScalar(double minVal, double maxVal);

  Vector clampLength<T extends num>(T min, T max);
  Vector floor();
  Vector ceil();
  Vector round();
  num distanceToSquared(Vector v);

  Vector roundToZero();
  Vector negate();
  num lengthSq();
  double length();
  num distanceTo(Vector v);

  num manhattanLength();
  Vector normalize();
  //double angle();
  Vector setLength(double length);
  Vector fromArray(dynamic array, [int offset = 0]);
  List<num> toArray([List<num> array, int offset = 0]);

  List<num> toList();
  Vector fromBufferAttribute(BufferAttribute attribute,int index);
  Vector random();
  Map<String, dynamic> toJSON();
}
