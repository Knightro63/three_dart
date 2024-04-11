import 'package:three_dart/three3d/math/index.dart';
import '../../constants.dart';
import '../keyframe_track.dart';

/// A Track of Boolean keyframe values.
class BooleanKeyframeTrack extends KeyframeTrack {
  // Note: Actually this track could have a optimized / compressed
  // representation of a single value and a custom interpolant that
  // computes "firstValue ^ isOdd( index )".
  BooleanKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]): super(name, times, values, null){
    valueBufferType = "Array";
    defaultInterpolation = InterpolateDiscrete;
    valueTypeName = 'bool';
  }

  @override
  Interpolant? interpolantFactoryMethodLinear(result){return null;}
  @override
  Interpolant? interpolantFactoryMethodSmooth(result){return null;}
  @override
  BooleanKeyframeTrack clone(){
    return BooleanKeyframeTrack(name, times, values);
  }
}
