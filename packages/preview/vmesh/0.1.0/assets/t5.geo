// https://gitlab.onelab.info/gmsh/gmsh/-/blob/master/tutorials/t5.geo
// -----------------------------------------------------------------------------
//
//  Gmsh GEO tutorial 5
//
//  Mesh sizes, macros, loops, holes in volumes
//
// -----------------------------------------------------------------------------

// We start by defining some target mesh sizes:

lcar1 = .1;
lcar2 = .0005;
lcar3 = .055;

// If we wanted to change these mesh sizes globally (without changing the above
// definitions), we could give a global scaling factor for all mesh sizes on the
// command line with the `-clscale' option (or with `Mesh.MeshSizeFactor' in an
// option file). For example, with:
//
// > gmsh t5.geo -clscale 1
//
// this input file produces a mesh of approximately 3000 nodes and 14,000
// tetrahedra. With
//
// > gmsh t5.geo -clscale 0.2
//
// the mesh counts approximately 231,000 nodes and 1,360,000 tetrahedra. You can
// check mesh statistics in the graphical user interface with the
// `Tools->Statistics' menu.
//
// See `t10.geo' for more information about mesh sizes.

// We proceed by defining some elementary entities describing a truncated cube:

Point(1) = {0.5,0.5,0.5,lcar2}; Point(2) = {0.5,0.5,0,lcar1};
Point(3) = {0,0.5,0.5,lcar1};   Point(4) = {0,0,0.5,lcar1};
Point(5) = {0.5,0,0.5,lcar1};   Point(6) = {0.5,0,0,lcar1};
Point(7) = {0,0.5,0,lcar1};     Point(8) = {0,1,0,lcar1};
Point(9) = {1,1,0,lcar1};       Point(10) = {0,0,1,lcar1};
Point(11) = {0,1,1,lcar1};      Point(12) = {1,1,1,lcar1};
Point(13) = {1,0,1,lcar1};      Point(14) = {1,0,0,lcar1};

Line(1) = {8,9};    Line(2) = {9,12};  Line(3) = {12,11};
Line(4) = {11,8};   Line(5) = {9,14};  Line(6) = {14,13};
Line(7) = {13,12};  Line(8) = {11,10}; Line(9) = {10,13};
Line(10) = {10,4};  Line(11) = {4,5};  Line(12) = {5,6};
Line(13) = {6,2};   Line(14) = {2,1};  Line(15) = {1,3};
Line(16) = {3,7};   Line(17) = {7,2};  Line(18) = {3,4};
Line(19) = {5,1};   Line(20) = {7,8};  Line(21) = {6,14};

Curve Loop(22) = {-11,-19,-15,-18};   Plane Surface(23) = {22};
Curve Loop(24) = {16,17,14,15};       Plane Surface(25) = {24};
Curve Loop(26) = {-17,20,1,5,-21,13}; Plane Surface(27) = {26};
Curve Loop(28) = {-4,-1,-2,-3};       Plane Surface(29) = {28};
Curve Loop(30) = {-7,2,-5,-6};        Plane Surface(31) = {30};
Curve Loop(32) = {6,-9,10,11,12,21};  Plane Surface(33) = {32};
Curve Loop(34) = {7,3,8,9};           Plane Surface(35) = {34};
Curve Loop(36) = {-10,18,-16,-20,4,-8}; Plane Surface(37) = {36};
Curve Loop(38) = {-14,-13,-12,19};    Plane Surface(39) = {38};

// Instead of using included files, we now use a user-defined macro in order
// to carve some holes in the cube:

Macro CheeseHole

  // In the following commands we use the reserved variable name `newp', which
  // automatically selects a new point tag. Analogously to `newp', the special
  // variables `newc', `newcl, `news', `newsl' and `newv' select new curve,
  // curve loop, surface, surface loop and volume tags.
  //
  // If `Geometry.OldNewReg' is set to 0, the new tags are chosen as the highest
  // current tag for each category (points, curves, curve loops, ...), plus
  // one. By default, for backward compatibility, `Geometry.OldNewReg' is set
  // to 1, and only two categories are used: one for points and one for the
  // rest.

  p1 = newp; Point(p1) = {x,  y,  z,  lcar3};
  p2 = newp; Point(p2) = {x+r,y,  z,  lcar3};
  p3 = newp; Point(p3) = {x,  y+r,z,  lcar3};
  p4 = newp; Point(p4) = {x,  y,  z+r,lcar3};
  p5 = newp; Point(p5) = {x-r,y,  z,  lcar3};
  p6 = newp; Point(p6) = {x,  y-r,z,  lcar3};
  p7 = newp; Point(p7) = {x,  y,  z-r,lcar3};

  c1 = newc; Circle(c1) = {p2,p1,p7}; c2 = newc; Circle(c2) = {p7,p1,p5};
  c3 = newc; Circle(c3) = {p5,p1,p4}; c4 = newc; Circle(c4) = {p4,p1,p2};
  c5 = newc; Circle(c5) = {p2,p1,p3}; c6 = newc; Circle(c6) = {p3,p1,p5};
  c7 = newc; Circle(c7) = {p5,p1,p6}; c8 = newc; Circle(c8) = {p6,p1,p2};
  c9 = newc; Circle(c9) = {p7,p1,p3}; c10 = newc; Circle(c10) = {p3,p1,p4};
  c11 = newc; Circle(c11) = {p4,p1,p6}; c12 = newc; Circle(c12) = {p6,p1,p7};

  // We need non-plane surfaces to define the spherical holes. Here we use
  // `Surface', which can be used for surfaces with 3 or 4 curves on their
  // boundary. With the built-in kernel, if all the curves are circle arcs with
  // the same center, a spherical patch is created; otherwise transfinite
  // interpolation is used. With the OpenCASCADE kernel, `Surface' can be used
  // with an arbitrary number of boundary curves, and will fit a BSpline patch
  // through them.

  l1 = newcl; Curve Loop(l1) = {c5,c10,c4};
  l2 = newcl; Curve Loop(l2) = {c9,-c5,c1};
  l3 = newcl; Curve Loop(l3) = {c12,-c8,-c1};
  l4 = newcl; Curve Loop(l4) = {c8,-c4,c11};
  l5 = newcl; Curve Loop(l5) = {-c10,c6,c3};
  l6 = newcl; Curve Loop(l6) = {-c11,-c3,c7};
  l7 = newcl; Curve Loop(l7) = {-c2,-c7,-c12};
  l8 = newcl; Curve Loop(l8) = {-c6,-c9,c2};

  s1 = news; Surface(s1) = {l1};
  s2 = news; Surface(s2) = {l2};
  s3 = news; Surface(s3) = {l3};
  s4 = news; Surface(s4) = {l4};
  s5 = news; Surface(s5) = {l5};
  s6 = news; Surface(s6) = {l6};
  s7 = news; Surface(s7) = {l7};
  s8 = news; Surface(s8) = {l8};

  // We then store the surface loops tags in a list for later reference (we will
  // need these to define the final volume):

  theloops[t] = newsl;
  Surface Loop(theloops[t]) = {s1, s2, s3, s4, s5, s6, s7, s8};

  thehole = newv;
  Volume(thehole) = theloops[t];

Return

// We can use a `For' loop to generate five holes in the cube:

x = 0; y = 0.75; z = 0; r = 0.09;

For t In {1:5}

  x += 0.166;
  z += 0.166;

  // We call the `CheeseHole' macro:

  Call CheeseHole;

  // We define a physical volume for each hole:

  Physical Volume (t) = thehole;

  // We also print some variables on the terminal (note that, since all
  // variables in `.geo' files are treated internally as floating point numbers,
  // the format string should only contain valid floating point format
  // specifiers like `%g', `%f', '%e', etc.):

  Printf("Hole %g (center = {%g,%g,%g}, radius = %g) has number %g!",
	 t, x, y, z, r, thehole);

EndFor

// We can then define the surface loop for the exterior surface of the cube:

theloops[0] = newreg;
Surface Loop(theloops[0]) = {23:39:2};

// The volume of the cube, without the 5 holes, is now defined by 6 surface
// loops: the first surface loop defines the exterior surface; the surface loops
// other than the first one define holes.  (Again, to reference an array of
// variables, its identifier is followed by square brackets):

Volume(186) = {theloops[]};

// Note that using solid modelling with the OpenCASCADE geometry kernel, the
// same geometry could be built quite differently: see `t16.geo'.

// We finally define a physical volume for the elements discretizing the cube,
// without the holes (for which physical groups were already created in the
// `For' loop):

Physical Volume (10) = 186;

// We could make only part of the model visible to only mesh this subset:
//
// Hide {:}
// Recursive Show { Volume{129}; }
// Mesh.MeshOnlyVisible=1;

// Meshing algorithms can changed globally using options:

Mesh.Algorithm = 6; // Frontal-Delaunay for 2D meshes

// They can also be set for individual surfaces, e.g.

MeshAlgorithm Surface {31, 35} = 1; // MeshAdapt on surfaces 31 and 35

// To generate a curvilinear mesh and optimize it to produce provably valid
// curved elements (see A. Johnen, J.-F. Remacle and C. Geuzaine. Geometric
// validity of curvilinear finite elements. Journal of Computational Physics
// 233, pp. 359-372, 2013; and T. Toulorge, C. Geuzaine, J.-F. Remacle,
// J. Lambrechts. Robust untangling of curvilinear meshes. Journal of
// Computational Physics 254, pp. 8-26, 2013), you can uncomment the following
// lines:
//
// Mesh.ElementOrder = 2;
// Mesh.HighOrderOptimize = 2;
