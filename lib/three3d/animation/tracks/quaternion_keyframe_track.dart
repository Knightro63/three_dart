import 'package:three_dart/three3d/math/index.dart';
import '../../constants.dart';
import '../keyframe_track.dart';

/// A Track of quaternion keyframe values.
class QuaternionKeyframeTrack extends KeyframeTrack {
  QuaternionKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]): super(name, times, values, interpolation){
    defaultInterpolation = InterpolateLinear;
    valueTypeName = 'quaternion';
  }

  @override
  Interpolant interpolantFactoryMethodLinear(result) {
    return QuaternionLinearInterpolant(times, values, getValueSize(), result);
  }

  @override
  Interpolant? interpolantFactoryMethodSmooth(result) {
    return null;
  }

  @override
  QuaternionKeyframeTrack clone(){
    return QuaternionKeyframeTrack(name, times, values);
  }
}
