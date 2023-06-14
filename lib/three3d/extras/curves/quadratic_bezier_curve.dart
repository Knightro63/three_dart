import 'package:three_dart/three3d/extras/core/interpolations.dart';
import 'package:three_dart/three3d/math/index.dart';

import '../core/curve.dart';

class QuadraticBezierCurve extends Curve {
  QuadraticBezierCurve(Vector2? v0, Vector2? v1, Vector2? v2) {
    type = 'QuadraticBezierCurve';

    this.v0 = v0 ?? Vector2();
    this.v1 = v1 ?? Vector2();
    this.v2 = v2 ?? Vector2();

    isQuadraticBezierCurve = true;
  }

  QuadraticBezierCurve.fromJSON(Map<String, dynamic> json)
      : super.fromJSON(json) {
    v0.fromArray(json["v0"]);
    v1.fromArray(json["v1"]);
    v2.fromArray(json["v2"]);
  }

  @override
  Vector? getPoint(t, [Vector? optionalTarget]) {
    var point = optionalTarget ?? Vector2();

    Vector2 v0 = this.v0, v1 = this.v1, v2 = this.v2;

    point.set(quadraticBezier(t, v0.x, v1.x, v2.x),
        quadraticBezier(t, v0.y, v1.y, v2.y));

    return point;
  }

  @override
  QuadraticBezierCurve copy(Curve source) {
    if(source is! QuadraticBezierCurve) throw('source Curve must be QuadraticBezierCurve');
    super.copy(source);

    v0.copy(source.v0);
    v1.copy(source.v1);
    v2.copy(source.v2);

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["v0"] = v0.toArray();
    data["v1"] = v1.toArray();
    data["v2"] = v2.toArray();

    return data;
  }
}
