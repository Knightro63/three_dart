import 'cylinder_geometry.dart';
import '../math/index.dart';

class ConeGeometry extends CylinderGeometry {
  ConeGeometry([
    double radius = 1,
    double height = 1,
    int radialSegments = 8,
    int heightSegments = 1,
    bool openEnded = false,
    num thetaStart = 0,
    double thetaLength = Math.pi * 2
  ]):super(0, radius, height, radialSegments, heightSegments, openEnded,thetaStart, thetaLength) {
    type = 'ConeGeometry';
    parameters = {
      "radius": radius,
      "height": height,
      "radialSegments": radialSegments,
      "heightSegments": heightSegments,
      "openEnded": openEnded,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };
  }
}
