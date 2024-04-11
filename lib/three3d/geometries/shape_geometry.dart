import 'package:flutter_gl/flutter_gl.dart';
import '../core/index.dart';
import '../math/index.dart';
import '../extras/index.dart';

class ShapeGeometry extends BufferGeometry {
  ShapeGeometry(List<Shape> shapes, {num curveSegments = 12}) : super() {
    type = 'ShapeGeometry';
    parameters = {};
    this.curveSegments = curveSegments;
    this.shapes = shapes;

    init();
  }

  ShapeGeometry.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON): super.fromJSON(json, rootJSON) {
    type = 'ShapeGeometry';
    curveSegments = json["curveSegments"];

    Shape? shps;

    if (json["shapes"] != null) {
      List<Shape> rootShapes = rootJSON["shapes"];

      String shapeUuid = json["shapes"];
      shps = rootShapes.firstWhere((element) => element.uuid == shapeUuid);
    }

    shapes = shps != null ? [shps] : [];

    init();
  }

  void init() {
    parameters!["shapes"] = shapes;
    parameters!["curveSegments"] = curveSegments;

    // buffers

    final indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    int groupStart = 0;
    int groupCount = 0;

    // allow single and array values for "shapes" parameter

    addShape(shape) {
      final indexOffset = vertices.length / 3;
      final points = shape.extractPoints(curveSegments);

      List<Vector?> shapeVertices = points["shape"];
      List<List<Vector?>> shapeHoles = (points["holes"] as List).map((item) => item as List<Vector?>).toList();

      // check direction of vertices

      if (ShapeUtils.isClockWise(shapeVertices) == false) {
        shapeVertices = shapeVertices.reversed.toList();
      }

      for (int i = 0, l = shapeHoles.length; i < l; i++) {
        final shapeHole = shapeHoles[i];

        if (ShapeUtils.isClockWise(shapeHole) == true) {
          shapeHoles[i] = shapeHole.reversed.toList();
        }
      }

      final faces = ShapeUtils.triangulateShape(shapeVertices, shapeHoles);

      // join vertices of inner and outer paths to a single array

      for (int i = 0, l = shapeHoles.length; i < l; i++) {
        final shapeHole = shapeHoles[i];
        shapeVertices.addAll(shapeHole);
      }

      // vertices, normals, uvs

      for (int i = 0, l = shapeVertices.length; i < l; i++) {
        final vertex = shapeVertices[i];
        if(vertex != null){
          vertices.addAll([vertex.x.toDouble(), vertex.y.toDouble(), 0.0]);
          normals.addAll([0.0, 0.0, 1.0]);
          uvs.addAll([vertex.x.toDouble(), vertex.y.toDouble()]); // world uvs
        }

      }

      // incides

      for (int i = 0, l = faces.length; i < l; i++) {
        final face = faces[i];

        final a = face[0] + indexOffset;
        final b = face[1] + indexOffset;
        final c = face[2] + indexOffset;

        indices.addAll([a.toInt(), b.toInt(), c.toInt()]);
        groupCount += 3;
      }
    }


    for (int i = 0; i < shapes.length; i++) {
      addShape(shapes[i]);
      addGroup(groupStart, groupCount, i); // enables MultiMaterial support
      groupStart += groupCount;
      groupCount = 0;
    }

    // if(shapes.runtimeType == List) {
    //   for ( final i = 0; i < shapes.length; i ++ ) {

    //     addShape( shapes[ i ] );

    //     this.addGroup( groupStart, groupCount, materialIndex: i ); // enables MultiMaterial support

    //     groupStart += groupCount;
    //     groupCount = 0;

    //   }
    // } else {
    // addShape( shapes );
    // }

    // build geometry

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute(
        'normal', Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));

    // helper functions
  }

  // addShape( List<num> vertices, List<num> normals, List<num> uvs, shape, groupCount ) {

  //   final indexOffset = vertices.length / 3;
  //   final points = shape.extractPoints( curveSegments );

  //   final shapeVertices = points["shape"];
  //   final shapeHoles = points["holes"];

  //   // check direction of vertices

  //   if ( ShapeUtils.isClockWise( shapeVertices ) == false ) {

  //     shapeVertices = shapeVertices.reversed.toList();

  //   }

  //   for ( final i = 0, l = shapeHoles.length; i < l; i ++ ) {

  //     final shapeHole = shapeHoles[ i ];

  //     if ( ShapeUtils.isClockWise( shapeHole ) == true ) {

  //       shapeHoles[ i ] = shapeHole.reversed.toList();

  //     }

  //   }

  //   final faces = ShapeUtils.triangulateShape( shapeVertices, shapeHoles );

  //   // join vertices of inner and outer paths to a single array

  //   for ( final i = 0, l = shapeHoles.length; i < l; i ++ ) {

  //     final shapeHole = shapeHoles[ i ];
  //     shapeVertices = shapeVertices.concat( shapeHole );

  //   }

  //   // vertices, normals, uvs

  //   for ( final i = 0, l = shapeVertices.length; i < l; i ++ ) {

  //     final vertex = shapeVertices[ i ];

  //     vertices..addAll([vertex.x, vertex.y, 0]);
  //     normals..addAll([0, 0, 1]);
  //     uvs..addAll([vertex.x, vertex.y]); // world uvs

  //   }

  //   // incides

  //   for ( final i = 0, l = faces.length; i < l; i ++ ) {

  //     final face = faces[ i ];

  //     final a = face[ 0 ] + indexOffset;
  //     final b = face[ 1 ] + indexOffset;
  //     final c = face[ 2 ] + indexOffset;

  //     indices.addAll( [a, b, c] );
  //     groupCount += 3;

  //   }

  // }

  @override
  Map<String,dynamic> toJSON({Object3dMeta? meta}) {
    final data = super.toJSON(meta: meta);

    final shapes = parameters!["shapes"];

    return toJSON2(shapes, data);
  }

  Map<String,dynamic> toJSON2(shapes, Map<String,dynamic> data) {
    if (shapes != null) {
      data["shapes"] = [];

      for (int i = 0, l = shapes.length; i < l; i++) {
        final shape = shapes[i];

        data["shapes"].add(shape.uuid);
      }
    }

    return data;
  }
}
