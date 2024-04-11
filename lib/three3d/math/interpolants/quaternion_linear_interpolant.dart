import '../interpolant.dart';
import '../quaternion.dart';

/// Spherical linear unit quaternion interpolant.

class QuaternionLinearInterpolant extends Interpolant {
  QuaternionLinearInterpolant(
    List<num> parameterPositions, 
    List<num> sampleValues, 
    int sampleSize, 
    List? resultBuffer
  ):super(parameterPositions, sampleValues, sampleSize, resultBuffer);

  @override
  List? interpolate(int i1, num t0, num t, num t1) {
    var result = resultBuffer;
    var values = sampleValues;
    var stride = valueSize;

    double v0 = t + (t0 * -1);
    double v1 = t1 + (t0 * -1);

    double alpha = v0 / v1;

    int offset = i1 * stride;

    for (int end = offset + stride; offset < end; offset += 4) {
      Quaternion.slerpFlat(
          result, 0, values, offset - stride, values, offset, alpha);
    }

    return result;
  }
}
