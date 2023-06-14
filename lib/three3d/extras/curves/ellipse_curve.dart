import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/math/index.dart';

class EllipseCurve extends Curve {
  late double aX;
  late double aY;
  late double xRadius;
  late double yRadius;

  late double aStartAngle;
  late double aEndAngle;

  late bool aClockwise;

  late double aRotation;

  @override
  bool isEllipseCurve = true;

  EllipseCurve([
    this.aX = 0, 
    this.aY = 0, 
    this.xRadius = 1, 
    this.yRadius = 1, 
    this.aStartAngle = 0, 
    this.aEndAngle = 2*Math.pi, 
    this.aClockwise = false, 
    this.aRotation = 0
  ]) {
    type = 'EllipseCurve';
  }

  EllipseCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    type = 'EllipseCurve';
    isEllipseCurve = true;

    aX = json["aX"];
    aY = json["aY"];

    xRadius = json["xRadius"];
    yRadius = json["yRadius"];

    aStartAngle = json["aStartAngle"];
    aEndAngle = json["aEndAngle"];

    aClockwise = json["aClockwise"];

    aRotation = json["aRotation"];
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    Vector2 point = (optionalTarget as Vector2?) ?? Vector2();
    double twoPi = Math.pi * 2;
    double deltaAngle = aEndAngle - aStartAngle;
    bool samePoints = Math.abs(deltaAngle) < Math.epsilon;

    // ensures that deltaAngle is 0 .. 2 PI
    while (deltaAngle < 0) {
      deltaAngle += twoPi;
    }
    while (deltaAngle > twoPi) {
      deltaAngle -= twoPi;
    }

    if (deltaAngle < Math.epsilon) {
      if (samePoints) {
        deltaAngle = 0;
      } else {
        deltaAngle = twoPi;
      }
    }

    if (aClockwise == true && !samePoints) {
      if (deltaAngle == twoPi) {
        deltaAngle = -twoPi;
      } else {
        deltaAngle = deltaAngle - twoPi;
      }
    }

    double angle = aStartAngle + t * deltaAngle;
    double x = aX + xRadius * Math.cos(angle);
    double y = aY + yRadius * Math.sin(angle);

    if (aRotation != 0) {
      double cos = Math.cos(aRotation);
      double sin = Math.sin(aRotation);

      double tx = x - aX;
      double ty = y - aY;

      // Rotate the point about the center of the ellipse.
      x = tx * cos - ty * sin + aX;
      y = tx * sin + ty * cos + aY;
    }

    return point.set(x, y);
  }

  @override
  EllipseCurve copy(Curve source) {
    if(source is! EllipseCurve) throw('source Curve must be EllipseCurve');
    super.copy(source);

    aX = source.aX;
    aY = source.aY;

    xRadius = source.xRadius;
    yRadius = source.yRadius;

    aStartAngle = source.aStartAngle;
    aEndAngle = source.aEndAngle;

    aClockwise = source.aClockwise;

    aRotation = source.aRotation;

    return this;
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = super.toJSON();

    data["aX"] = aX;
    data["aY"] = aY;

    data["xRadius"] = xRadius;
    data["yRadius"] = yRadius;

    data["aStartAngle"] = aStartAngle;
    data["aEndAngle"] = aEndAngle;

    data["aClockwise"] = aClockwise;

    data["aRotation"] = aRotation;

    return data;
  }
}
