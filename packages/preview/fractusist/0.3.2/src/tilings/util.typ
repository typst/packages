//==============================================================================
// Utility functions for 2D geometry
//==============================================================================


// Linearly interpolates between two points and returns its position
// pa: start point
// pb: end point
// t: position on the line [0, 1], 0 for pa, 1 for pb
#let pt-lerp(pa, pb, t) = {
  (pa.at(0) + (pb.at(0) - pa.at(0)) * t, pa.at(1) + (pb.at(1) - pa.at(1)) * t)
}


// Rotate around the reference point
// p0: reference point
// p: point to rotate
// angle: anticlockwise rotation angle
#let pt-rot(p0, p, angle) = {
  let (vx, vy) = (p.at(0) - p0.at(0), p.at(1) - p0.at(1))
  let (cx, cy) = (calc.cos(angle), calc.sin(angle))
  (p0.at(0) + vx * cx - vy * cy, p0.at(1) + vx * cy + vy * cx)
}


// Rotate and scale around the reference point
// p0: reference point
// p: point to rotate and scale
// a: anticlockwise rotation angle
// s: scale value (positive)
#let pt-rot-sc(p0, p, a, s) = {
  let (vx, vy) = (p.at(0) - p0.at(0), p.at(1) - p0.at(1))
  let (cx, cy) = (calc.cos(a) * s, calc.sin(a) * s)
  (p0.at(0) + vx * cx - vy * cy, p0.at(1) + vx * cy + vy * cx)
}
