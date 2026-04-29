// https://www.math.univ-paris13.fr/~cuvelier/software/gmshgeo.html
N=4;
R=1;

h=R/N;
// h=5;
// R=5;
// 2/ Points :

Point(1) = {0,0,0,h};
Point(2) = {R,0,0,h};
Point(3) = {0,R,0,h};
Point(4) = {0,0,R,h};
Point(5) = {-R,0,0,h};
Point(6) = {0,-R,0,h};
Point(7) = {0,0,-R,h};

// 3/ Arcs :


Circle(1) = {2,1,3};
Circle(2) = {3,1,5};
Circle(3) = {5,1,6};
Circle(4) = {6,1,2};
Circle(5) = {2,1,7};
Circle(6) = {7,1,5};
Circle(7) = {5,1,4};
Circle(8) = {4,1,2};
Circle(9) = {6,1,7};
Circle(10) = {7,1,3};
Circle(11) = {3,1,4};
Circle(12) ={4,1,6};


// 4/ Contours :

Line Loop(1) = {1,11,8};
Line Loop(2) = {2,7,-11};
Line Loop(3) = {3,-12,-7};
Line Loop(4) = {4,-8,12};
Line Loop(5) = {5,10,-1};
Line Loop(6) = {-2,-10,6};
Line Loop(7) = {-3,-6,-9};
Line Loop(8) = {-4,9,-5};


// 5/ Surfaces :


Surface(1) = {1};
Surface(2) = {2};
Surface(3) = {3};
Surface(4) = {4};
Surface(5) = {5};
Surface(6) = {6};
Surface(7) = {7};
Surface(8) = {8};


Surface Loop (21) = {1,2,3,4,5,6,7,8};

// 6/ Volume final :

Surface(23) = {1};
Surface(24) = {5};
Surface(25) = {6};
Surface(26) = {2};
Surface(27) = {3};
Surface(28) = {4};
Surface(29) = {8};
Surface(30) = {7};
Volume(31) = {21};
Physical Surface(1) = {3};
Physical Surface(5) = {7};
Physical Surface(4) = {2};
Physical Surface(3) = {1};
Physical Surface(7) = {5};
Physical Surface(6) = {8};
Physical Surface(8) = {6};
Physical Surface(2) = {4};
Physical Volume(1) = {31};
Physical Line(11) = {11};
Physical Line(10) = {10};
Physical Line(12) = {12};
Physical Line(9) = {9};
Physical Line(6) = {6};
Physical Line(5) = {5};
Physical Line(8) = {8};
Physical Line(7) = {7};
Physical Line(2) = {2};
Physical Line(1) = {1};
Physical Line(4) = {4};
Physical Line(3) = {3};
Physical Point(106) = {7};
Physical Point(101) = {2};
Physical Point(103) = {4};
Physical Point(104) = {5};
Physical Point(102) = {3};
Physical Point(105) = {6};
