import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/extras/core/path.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'curve.dart';

class ShapeExtractPoints{
  ShapeExtractPoints({
    required this.shape,
    required this.holes
  });

  List<Vector> shape;
  List<List<Vector>?> holes;
}

class Shape extends Path {
  late String uuid;
  late List<Path> holes;

  Shape([points]):super(points) {
    uuid = MathUtils.generateUUID();
    holes = [];
  }

  Shape.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    type = "Shape";
    uuid = json["uuid"];
    holes = [];

    for (int i = 0, l = json["holes"].length; i < l; i++) {
      var hole = json["holes"][i];
      holes.add(Path.fromJSON(hole));
    }
  }

  List<List<Vector>?> getPointsHoles(int divisions) {
    List<List<Vector>?> holesPts = List<List<Vector>?>.filled(holes.length, null);

    for (int i = 0, l = holes.length; i < l; i++) {
      holesPts[i] = holes[i].getPoints(divisions);
    }

    return holesPts;
  }

  // get points of shape and holes (keypoints based on segments parameter)

  ShapeExtractPoints extractPoints(int divisions) {
    return ShapeExtractPoints(
      shape: getPoints(divisions),
      holes: getPointsHoles(divisions)
    );
  }

  @override
  Shape copy(Curve source) {
    if(source is! Shape) throw('source Curve must be Shape');
    super.copy(source);

    holes = [];

    for (int i = 0, l = source.holes.length; i < l; i++) {
      Path hole = source.holes[i];

      holes.add(hole.clone());
    }

    return this;
  }

  @override
  Map<String,dynamic> toJSON({Object3dMeta? meta}) {
    Map<String,dynamic> data = super.toJSON();

    data["uuid"] = uuid;
    data["holes"] = [];

    for (int i = 0, l = holes.length; i < l; i++) {
      Path hole = holes[i];
      data["holes"].add(hole.toJSON());
    }

    return data;
  }

  @override
  Shape fromJSON(json) {
    super.fromJSON(json);

    uuid = json.uuid;
    holes = [];

    for (int i = 0, l = json.holes.length; i < l; i++) {
      var hole = json.holes[i];
      holes.add(Path.fromJSON(hole));
    }

    return this;
  }
}
