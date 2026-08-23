
lc = 0.2;

//+
Point(1) = {0, 0, 0, lc};
//+
Extrude {1, 0, 0} {
  Point{1}; Layers {4}; Recombine;
}
//+
Extrude {0, 0.5, 0} {
  Curve{1}; Layers {4}; Recombine;
}
//+
Extrude {0, 0.5, 0} {
  Curve{2}; Layers {3}; Recombine;
}
//+
Physical Surface(1) = {5};
//+
Physical Surface(2) = {9};
//+
Circle(9) = {5, 3, 1};//+
Curve Loop(1) = {9, 3, 7};
//+
Plane Surface(10) = {1};
//+
Physical Surface(3) = {10};
//+
Physical Curve(4) = {9};
//+
Physical Curve(6) = {8, 4};
//+
Physical Curve(5) = {6, 1};
