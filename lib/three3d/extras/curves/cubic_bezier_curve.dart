import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/extras/core/interpolations.dart';
import 'package:three_dart/three3d/math/index.dart';

class CubicBezierCurve extends Curve {
  late Vector2 v3;

  CubicBezierCurve(Vector2? v0, Vector2? v1, Vector2? v2, Vector2? v3) {
    type = 'CubicBezierCurve';

    this.v0 = v0 ?? Vector2();
    this.v1 = v1 ?? Vector2();
    this.v2 = v2 ?? Vector2();
    this.v3 = v3 ?? Vector2();

    isCubicBezierCurve = true;
  }

  CubicBezierCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    v0.fromArray(json["v0"]);
    v1.fromArray(json["v1"]);
    v2.fromArray(json["v2"]);
    v3.fromArray(json["v3"]);
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    Vector point = optionalTarget ?? Vector2();

    Vector v0 = this.v0, v1 = this.v1, v2 = this.v2, v3 = this.v3;

    point.set(
      cubicBezier(t, v0.x, v1.x, v2.x, v3.x),
      cubicBezier(t, v0.y, v1.y, v2.y, v3.y),
    );

    return point;
  }

  @override
  CubicBezierCurve copy(Curve source) {
    if(source is! CubicBezierCurve) throw('source Curve must be CubicBezierCurve');
    super.copy(source);

    v0.copy(source.v0);
    v1.copy(source.v1);
    v2.copy(source.v2);
    v3.copy(source.v3);

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["v0"] = v0.toArray();
    data["v1"] = v1.toArray();
    data["v2"] = v2.toArray();
    data["v3"] = v3.toArray();

    return data;
  }
}
