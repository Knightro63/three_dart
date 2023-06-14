
/// Bezier Curves formulas obtained from
/// http://en.wikipedia.org/wiki/Bézier_curve

double catmullRom(num t,num p0,num p1,num p2,num p3) {
  double v0 = (p2 - p0) * 0.5;
  double v1 = (p3 - p1) * 0.5;
  double t2 = t * t.toDouble();
  double t3 = t * t2;
  return (2 * p1 - 2 * p2 + v0 + v1) * t3 +
      (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 +
      v0 * t +
      p1;
}

//
double quadraticBezierP0(num t, num p) {
  double k = 1 - t.toDouble();
  return k * k * p;
}

double quadraticBezierP1(num t,num p) {
  return 2 * (1 - t) * t.toDouble() * p;
}

double quadraticBezierP2(num t,num p) {
  return t * t.toDouble() * p;
}

double quadraticBezier(num t,num p0,num p1,num p2) {
  return quadraticBezierP0(t, p0) +
      quadraticBezierP1(t, p1) +
      quadraticBezierP2(t, p2);
}

//
double cubicBezierP0(num t,num p) {
  double k = 1 - t.toDouble();
  return k * k * k * p;
}

double cubicBezierP1(num t,num p) {
  double k = 1 - t.toDouble();
  return 3 * k * k * t * p;
}

double cubicBezierP2(num t,num p) {
  return 3 * (1 - t) * t * t.toDouble() * p;
}

double cubicBezierP3(num t,num p) {
  return t * t * t.toDouble() * p;
}

double cubicBezier(num t,num p0,num p1,num p2,num p3) {
  return cubicBezierP0(t, p0) +
      cubicBezierP1(t, p1) +
      cubicBezierP2(t, p2) +
      cubicBezierP3(t, p3);
}
