import '../keyframe_track.dart';

/// A Track of numeric keyframe values.
class NumberKeyframeTrack extends KeyframeTrack {
  NumberKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]): super(name, times, values, interpolation){
    valueTypeName = "number";
  }
  @override
  NumberKeyframeTrack clone(){
    return NumberKeyframeTrack(name, times, values);
  }
}
