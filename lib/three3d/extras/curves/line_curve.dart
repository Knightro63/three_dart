import '../../math/index.dart';
import '../core/curve.dart';

class LineCurve extends Curve {
  LineCurve(Vector v1, Vector v2) {
    if(v1 is! Vector2){
      v1 = Vector2(v1.x,v1.y);
    }
    if(v2 is! Vector2){
      v2 = Vector2(v2.x,v2.y);
    }
    this.v1 = v1;
    this.v2 = v2;
    isLineCurve = true;
  }

  LineCurve.fromJSON(Map<String, dynamic> json):super.fromJSON(json){
    isLineCurve = true;
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    final point = optionalTarget ?? Vector2();

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
  Vector? getPointAt(num u, [Vector? optionalTarget]) {
    return getPoint(u, optionalTarget);
  }

  @override
  Vector getTangent(num t, [Vector? optionalTarget]) {
    final tangent = optionalTarget ?? Vector2();
    tangent.copy(v2).sub(v1).normalize();
    return tangent;
  }

  @override
  LineCurve copy(source) {
    super.copy(source);

    v1.copy(source.v1);
    v2.copy(source.v2);

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["v1"] = v1.toArray();
    data["v2"] = v2.toArray();

    return data;
  }
}

class LineCurve3 extends Curve {}
