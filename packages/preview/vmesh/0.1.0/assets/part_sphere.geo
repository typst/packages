// https://www.math.univ-paris13.fr/~cuvelier/software/gmshgeo.html
N=5;
R=3; // radius 
r=2;  // radius
h=1/N;
// 1/ Points :

Point(1) = {0,0,0,h};
Point(2) = {R,0,0,h};
Point(3) = {0,R,0,h};
Point(4) = {0,0,R,h};

Point(11) = {r,0,0,h};
Point(12) = {0,r,0,h};
Point(13) = {0,0,r,h};
Circle(1) = {3, 1, 4};
Circle(2) = {3, 1, 2};
Circle(3) = {4, 1, 2};

Line Loop(4) = {1, 3, -2};
Surface(5) = {4};
Circle(6) = {12, 1, 13};
Circle(7) = {12, 1, 11};
Circle(8) = {11, 1, 13};
Line Loop(9) = {6, -8, -7};
Surface(10) = {9};
Line(11) = {13, 4};
Line(12) = {12, 3};
Line(13) = {11, 2};
Line Loop(14) = {12, 1, -11, -6};
Plane Surface(15) = {14};
Line Loop(16) = {11, 3, -13, 8};
Plane Surface(17) = {16};
Line Loop(18) = {13, -2, -12, 7};
Plane Surface(19) = {18};
Physical Surface(20) = {15};
Physical Surface(21) = {19};
Physical Surface(22) = {10};
Physical Surface(23) = {5};
Physical Surface(24) = {17};
Surface Loop(30) = {15, 19, 17, 5, 10};
Volume(25) = {30};
Physical Volume(26) = {25};
