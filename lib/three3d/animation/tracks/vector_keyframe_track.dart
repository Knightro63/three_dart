import '../keyframe_track.dart';

/// A Track of vectored keyframe values.
class VectorKeyframeTrack extends KeyframeTrack {
  VectorKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]):super(name, times, values, interpolation){
    valueTypeName = 'vector';
  }

  @override
  VectorKeyframeTrack clone(){
    return VectorKeyframeTrack(name, times, values);
  }
}
