import '../../math/index.dart';
import '../core/curve.dart';
import '../core/interpolations.dart';

class QuadraticBezierCurve extends Curve {
  QuadraticBezierCurve(Vector2? v0, Vector2? v1, Vector2? v2) {

    this.v0 = v0 ?? Vector2(null, null);
    this.v1 = v1 ?? Vector2(null, null);
    this.v2 = v2 ?? Vector2(null, null);

    isQuadraticBezierCurve = true;
  }

  QuadraticBezierCurve.fromJSON(Map<String, dynamic> json)
      : super.fromJSON(json) {
    v0.fromArray(json["v0"]);
    v1.fromArray(json["v1"]);
    v2.fromArray(json["v2"]);

    isQuadraticBezierCurve = true;
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    final point = optionalTarget ?? Vector2(null, null);

    final v0 = this.v0, v1 = this.v1, v2 = this.v2;

    point.set(PathInterpolations.quadraticBezier(t, v0.x, v1.x, v2.x),
        PathInterpolations.quadraticBezier(t, v0.y, v1.y, v2.y));

    return point;
  }

  @override
  QuadraticBezierCurve copy(Curve source) {
    if(source is QuadraticBezierCurve){
      super.copy(source);

      v0.copy(source.v0);
      v1.copy(source.v1);
      v2.copy(source.v2);
    }

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
