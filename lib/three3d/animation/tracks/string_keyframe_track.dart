import 'package:three_dart/three3d/math/index.dart';
import '../../constants.dart';
import '../keyframe_track.dart';

/// A Track that interpolates Strings
class StringKeyframeTrack extends KeyframeTrack {
  StringKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]):super(name, times, values, interpolation){
    defaultInterpolation = InterpolateDiscrete;
    valueBufferType = "Array";
    valueTypeName = 'string';
  }

  @override
  Interpolant? interpolantFactoryMethodLinear(result){return null;}

  @override
  Interpolant? interpolantFactoryMethodSmooth(result) {return null;}

  @override
  StringKeyframeTrack clone(){
    return StringKeyframeTrack(name, times, values);
  }
}
