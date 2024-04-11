import 'path.dart';
import '../../math/index.dart';
import '../../core/object_3d.dart';

class Shape extends Path {
  late String uuid;
  late List<Path> holes;

  Shape([points]) : super(points) {
    uuid = MathUtils.generateUUID();
    holes = [];
  }

  Shape.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    uuid = json["uuid"];
    holes = [];

    for (int i = 0, l = json["holes"].length; i < l; i++) {
      final hole = json["holes"][i];
      holes.add(Path.fromJSON(hole));
    }
  }

  List<List<Vector?>?> getPointsHoles(int divisions) {
    final holesPts = List<List<Vector?>?>.filled(holes.length, null);

    for (int i = 0, l = holes.length; i < l; i++) {
      holesPts[i] = holes[i].getPoints(divisions);
    }

    return holesPts;
  }

  // get points of shape and holes (keypoints based on segments parameter)

  Map<String, dynamic> extractPoints(divisions) {
    return {
      "shape": getPoints(divisions),
      "holes": getPointsHoles(divisions)
    };
  }

  @override
  Shape copy(source){
    if(source is Shape){
      super.copy(source);

      holes = [];
      for (int i = 0, l = source.holes.length; i < l; i++) {
        final hole = source.holes[i];
        holes.add(hole.clone() as Shape);
      }
    }

    return this;
  }

  @override
   Map<String,dynamic> toJSON({Object3dMeta? meta}) {
    Map<String,dynamic> data = super.toJSON();

    data["uuid"] = uuid;
    data["holes"] = [];

    for (int i = 0, l = holes.length; i < l; i++) {
      final hole = holes[i];
      data["holes"].add(hole.toJSON());
    }

    return data;
  }

  @override
  Shape fromJSON(Map<String,dynamic> json) {
    super.fromJSON(json);

    uuid = json['uuid'];
    holes = [];

    for (int i = 0, l = json['holes'].length; i < l; i++) {
      final hole = json['holes'][i];
      holes.add(Path(null).fromJSON(hole));
    }

    return this;
  }
  @override
  Shape moveTo(num x, num y) {
    super.moveTo(x, y);
    return this;
  }
  @override
  Shape lineTo(num x, num y) {
    super.lineTo(x, y);
    return this;
  }
  @override
  Shape absarc(num aX, num aY, num aRadius, num aStartAngle, num aEndAngle, [bool? aClockwise]) {
    super.absarc(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise);
    return this;
  }
  @override
  Shape quadraticCurveTo(num aCPx, num aCPy, num aX, num aY) {
    super.quadraticCurveTo(aCPx, aCPy, aX, aY);
    return this;
  }
  @override
  Shape bezierCurveTo(num aCP1x, num aCP1y, num aCP2x, num aCP2y, num aX, num aY) {
    super.bezierCurveTo(aCP1x, aCP1y, aCP2x, aCP2y, aX, aY);
    return this;
  }
  @override
  Shape splineThru(List<Vector2> pts) {
    super.splineThru(pts);
    return this;
  }
  @override
  Shape arc(num aX, num aY, num aRadius, num aStartAngle, num aEndAngle, [bool? aClockwise]) {
    super.arc(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise);
    return this;
  }
  @override
  Shape ellipse(num aX, num aY, num xRadius, num yRadius, num aStartAngle, num aEndAngle, [bool? aClockwise, num? aRotation]) {
    super.ellipse(aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation);
    return this;
  }
  @override
  Shape absellipse(num aX, num aY, num xRadius, num yRadius, num aStartAngle, num aEndAngle, [bool? aClockwise, num? aRotation]) {
    super.absellipse(aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation);
    return this;
  }
}
