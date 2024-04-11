import '../keyframe_track.dart';

/// A Track of keyframe values that represent color.
class ColorKeyframeTrack extends KeyframeTrack {
  ColorKeyframeTrack(String name, List<num> times, List<num> values, [int? interpolation]):super(name, times, values, interpolation){
    valueTypeName = 'color';
  }

  @override
  ColorKeyframeTrack clone(){
    return ColorKeyframeTrack(name, times, values);
  }
}
