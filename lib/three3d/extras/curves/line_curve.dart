import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/math/index.dart';

class LineCurve extends Curve {
  @override
  bool isLineCurve = true;

  LineCurve(Vector2 v1, Vector2 v2) {
    type = 'LineCurve';

    this.v1 = v1;
    this.v2 = v2;
  }

  LineCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json);

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    var point = optionalTarget ?? Vector2();

    if (t == 1) {
      point.copy(v2);
    } else {
      point.copy(v2).sub(v1);
      point.multiplyScalar(t).add(v1);
    }

    return point;
  }

  // Line curve is linear, so we can overwrite default getPointAt

  @override
  Vector? getPointAt(int u, [Vector? optionalTarget]) {
    return getPoint(u, optionalTarget);
  }

  @override
  Vector? getTangent(int t, [Vector? optionalTarget]) {
    var tangent = optionalTarget ?? Vector2();
    tangent.copy(v2).sub(v1).normalize();
    return tangent;
  }

  @override
  LineCurve copy(Curve source) {
    if(source is! LineCurve) throw('source Curve must be LineCurve');
    super.copy(source);

    v1.copy(source.v1);
    v2.copy(source.v2);

    return this;
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = super.toJSON();

    data["v1"] = v1.toArray();
    data["v2"] = v2.toArray();
    return data;
  }
}

class LineCurve3 extends Curve {
  late Vector3 vec1;
  late Vector3 vec2;

  LineCurve3(this.vec1, this.vec2) {
    isLineCurve = true;
    type = 'LineCurve3';
  }

  LineCurve3.fromJSON(Map<String, dynamic> json) {
    arcLengthDivisions = json["arcLengthDivisions"];

    isLineCurve = true;
    type = 'LineCurve3';

    vec1 = Vector3.fromJSON(json['vec1']);
    vec2 = Vector3.fromJSON(json['vec2']);
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    Vector point = optionalTarget ?? Vector3(null, null, null);

    if (t == 1) {
      point.copy(vec2);
    } else {
      point.copy(vec2).sub(vec1);
      point.multiplyScalar(t).add(vec1);
    }

    return point;
  }

  // Line curve is linear, so we can overwrite default getPointAt

  @override
  Vector? getPointAt(int u, [Vector? optionalTarget]) {
    return getPoint(u, optionalTarget);
  }

  @override
  Vector? getTangent(int t, [Vector? optionalTarget]) {
    Vector tangent = optionalTarget ?? Vector3(null, null, null);

    tangent.copy(vec2).sub(vec1).normalize();

    return tangent;
  }

  @override
  Curve copy(Curve source) {
    if(source is! LineCurve3) throw('source Curve must be LineCurve3');
    super.copy(source);

    isLineCurve = true;

    vec1.copy(source.vec1);
    vec2.copy(source.vec2);

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["vec1"] = vec1.toArray();
    data["vec2"] = vec2.toArray();

    return data;
  }
}
