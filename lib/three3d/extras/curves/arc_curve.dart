import 'ellipse_curve.dart';

class ArcCurve extends EllipseCurve{
  bool isArcCurve = true;
  ArcCurve(num aX, num aY, num aRadius,num  aStartAngle, num aEndAngle, bool aClockwise )
    :super(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise);
}
