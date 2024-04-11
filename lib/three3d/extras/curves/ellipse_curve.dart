import '../../math/index.dart';
import '../core/curve.dart';

class EllipseCurve extends Curve {
  late num aX;
  late num aY;
  late num xRadius;
  late num yRadius;

  late num aStartAngle;
  late num aEndAngle;
  late bool aClockwise;
  late num aRotation;

  EllipseCurve(aX, aY, xRadius, yRadius, [aStartAngle, aEndAngle, aClockwise, aRotation]) {

    this.aX = aX ?? 0;
    this.aY = aY ?? 0;

    this.xRadius = xRadius ?? 1;
    this.yRadius = yRadius ?? 1;

    this.aStartAngle = aStartAngle ?? 0;
    this.aEndAngle = aEndAngle ?? 2 * Math.pi;

    this.aClockwise = aClockwise ?? false;

    this.aRotation = aRotation ?? 0;

    isEllipseCurve = true;
  }

  EllipseCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    aX = json["aX"];
    aY = json["aY"];

    xRadius = json["xRadius"];
    yRadius = json["yRadius"];

    aStartAngle = json["aStartAngle"];
    aEndAngle = json["aEndAngle"];

    aClockwise = json["aClockwise"];

    aRotation = json["aRotation"];

    isEllipseCurve = true;
  }

  @override
  Vector? getPoint(num t, [Vector? optionalTarget]) {
    final point = optionalTarget ?? Vector2(null, null);

    final twoPi = Math.pi * 2;
    num deltaAngle = aEndAngle - aStartAngle;
    final samePoints = Math.abs(deltaAngle) < Math.epsilon;

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

    final angle = aStartAngle + t * deltaAngle;
    double x = aX + xRadius * Math.cos(angle);
    double y = aY + yRadius * Math.sin(angle);

    if (aRotation != 0) {
      final cos = Math.cos(aRotation);
      final sin = Math.sin(aRotation);

      final tx = x - aX;
      final ty = y - aY;

      // Rotate the point about the center of the ellipse.
      x = tx * cos - ty * sin + aX;
      y = tx * sin + ty * cos + aY;
    }

    return point.set(x, y);
  }

  @override
  EllipseCurve copy(Curve source) {
    if(source is EllipseCurve){
      super.copy(source);

      aX = source.aX;
      aY = source.aY;

      xRadius = source.xRadius;
      yRadius = source.yRadius;

      aStartAngle = source.aStartAngle;
      aEndAngle = source.aEndAngle;

      aClockwise = source.aClockwise;

      aRotation = source.aRotation;
    }

    return this;
  }

  @override
  Map<String,dynamic> toJSON() {
    Map<String,dynamic> data = super.toJSON();

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
