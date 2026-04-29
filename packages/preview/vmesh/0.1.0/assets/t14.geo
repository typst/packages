// https://gitlab.onelab.info/gmsh/gmsh/-/blob/master/tutorials/t14.geo
// -----------------------------------------------------------------------------
//
//  Gmsh GEO tutorial 14
//
//  Homology and cohomology computation
//
// -----------------------------------------------------------------------------

// Homology computation in Gmsh finds representative chains of (relative)
// (co)homology space bases using a mesh of a model.  The representative basis
// chains are stored in the mesh as physical groups of Gmsh, one for each chain.

// Create an example geometry

m = 0.5; // mesh size
h = 2; // height in the z-direction

Point(1) = {0, 0, 0, m};   Point(2) = {10, 0, 0, m};
Point(3) = {10, 10, 0, m}; Point(4) = {0, 10, 0, m};
Point(5) = {4, 4, 0, m};   Point(6) = {6, 4, 0, m};
Point(7) = {6, 6, 0, m};   Point(8) = {4, 6, 0, m};

Point(9) = {2, 0, 0, m};   Point(10) = {8, 0, 0, m};
Point(11) = {2, 10, 0, m}; Point(12) = {8, 10, 0, m};

Line(1) = {1, 9};  Line(2) = {9, 10}; Line(3) = {10, 2};
Line(4) = {2, 3};  Line(5) = {3, 12}; Line(6) = {12, 11};
Line(7) = {11, 4}; Line(8) = {4, 1};  Line(9) = {5, 6};
Line(10) = {6, 7}; Line(11) = {7, 8}; Line(12) = {8, 5};

Curve Loop(13) = {6, 7, 8, 1, 2, 3, 4, 5};
Curve Loop(14) = {11, 12, 9, 10};
Plane Surface(15) = {13, 14};

e() = Extrude {0, 0, h}{ Surface{15}; };

// Create physical groups, which are used to define the domain of the
// (co)homology computation and the subdomain of the relative (co)homology
// computation.

// Whole domain
Physical Volume(1) = {e(1)};

// Four "terminals" of the model
Physical Surface(70) = {e(3)};
Physical Surface(71) = {e(5)};
Physical Surface(72) = {e(7)};
Physical Surface(73) = {e(9)};

// Whole domain surface
bnd() = Boundary{ Volume{e(1)}; };
Physical Surface(80) = bnd();

// Complement of the domain surface with respect to the four terminals
bnd() -= {e(3), e(5), e(7), e(9)};
Physical Surface(75) = bnd();

// Find bases for relative homology spaces of the domain modulo the four
// terminals.
Homology {{1}, {70, 71, 72, 73}};

// Find homology space bases isomorphic to the previous bases: homology spaces
// modulo the non-terminal domain surface, a.k.a the thin cuts.
Homology {{1}, {75}};

// Find cohomology space bases isomorphic to the previous bases: cohomology
// spaces of the domain modulo the four terminals, a.k.a the thick cuts.
Cohomology {{1}, {70, 71, 72, 73}};

// More examples:
//  Homology {1};
//  Homology;
//  Homology {{1}, {80}};
//  Homology {{}, {80}};

// For more information, see M. Pellikka, S. Suuriniemi, L. Kettunen and
// C. Geuzaine. Homology and cohomology computation in finite element
// modeling. SIAM Journal on Scientific Computing 35(5), pp. 1195-1214, 2013.