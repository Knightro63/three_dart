import 'package:three_dart/three_dart.dart';

class SplineCurve extends Curve {
  SplineCurve(points) : super() {
    type = 'SplineCurve';
    this.points = points;
    isSplineCurve = true;
  }

  SplineCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    points = [];

    for (int i = 0, l = json["points"].length; i < l; i++) {
      var point = json["points"][i];
      points.add(Vector2().fromArray(point));
    }
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    var point = optionalTarget ?? Vector2();

    List<Vector> points = this.points;
    num p = (points.length - 1) * t;

    int intPoint = Math.floor(p).toInt();
    double weight = p - intPoint.toDouble();

    Vector p0 = points[intPoint == 0 ? intPoint : intPoint - 1];
    Vector p1 = points[intPoint];
    Vector p2 =
        points[intPoint > points.length - 2 ? points.length - 1 : intPoint + 1];
    Vector p3 =
        points[intPoint > points.length - 3 ? points.length - 1 : intPoint + 2];

    point.set(catmullRom(weight, p0.x, p1.x, p2.x, p3.x),
        catmullRom(weight, p0.y, p1.y, p2.y, p3.y));

    return point;
  }

  @override
  SplineCurve copy(source) {
    if(source is! LineCurve) throw('source Curve must be LineCurve');
    super.copy(source);

    points = [];

    for (int i = 0, l = source.points.length; i < l; i++) {
      Vector point = source.points[i];

      points.add(point.clone());
    }

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

    data["points"] = [];

    for (int i = 0, l = points.length; i < l; i++) {
      Vector point = points[i];
      data["points"].add(point.toArray());
    }

    return data;
  }
}
