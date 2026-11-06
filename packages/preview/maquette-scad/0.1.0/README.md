<p align="center"><img src="https://raw.githubusercontent.com/bernsteining/maquette/maquette-scad-v0.1.0/docs/logo-scad.svg" width="180" alt="maquette-scad logo"></p>

# maquette-scad

[![Typst Universe](https://img.shields.io/badge/Typst%20Universe-maquette--scad-239dad)](https://typst.app/universe/package/maquette-scad)
[![Live demo](https://img.shields.io/badge/demo-live-4f46e5)](https://bernsteining.github.io/maquette/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Render OpenSCAD files in Typst with `maquette-scad`. 

Load `.scad` files, or use the Typst DSL to render them with [maquette](https://github.com/bernsteining/maquette). 

**[Try it live →](https://bernsteining.github.io/maquette/?a=__scad__)**  edit SCAD source, orbit the result, tweak the render, and copy the generated Typst code snippet.

> **Download models to try it out on** [Thingiverse](https://www.thingiverse.com/search?q=openscad&page=1).

## Usage

Three ways in: 
* a **`.scad` file**
* the Typst **DSL**
* a **multi-file project**

<table>
<tr><th colspan="2" align="left">1. OpenSCAD file</th></tr>
<tr>
<td>

```scad
// example.scad
$fn = 100;
module rod(d, h) cylinder(h, d = d, center = true);
hole = 25;
len = 62.5;
difference() {
  sphere(d = 50);
  rod(hole, len);
  rotate([90, 0, 0]) rod(hole, len);
}
color([0.5, 0.3, 0.1, 0.6])
rotate([0, 90, 0]) rod(hole, len);
```

```typst
#import "@preview/maquette-scad:0.1.0": render-scad

#render-scad(
  read("example.scad"),
  azimuth: 219,
  elevation: 33,
  up: (0, 1, 0),
  fov: 40,
  zoom: 1.2,
  background: none,
)
```

</td>
<td><a href="https://bernsteining.github.io/maquette/?model=openscad-logo.scad&azimuth=219&elevation=33&up=%5B0%2C1%2C0%5D&fov=40&zoom=1.2&color=%22%23f9d72c%22&specular=0&cull_backface=false&background=%22none%22" title="Open in the live demo"><img src="https://raw.githubusercontent.com/bernsteining/maquette/maquette-scad-v0.1.0/examples/readme/scad-logo.png" width="300" alt="OpenSCAD logo compiled from source" /></a></td>
</tr>
<tr><th colspan="2" align="left">2. DSL</th></tr>
<tr>
<td>

```typst
#import "@preview/maquette-scad:0.1.0": *

#let bore = cylinder(30, r: 4.5, center: true, fn: 48)
#render-scad(
  color((0.16, 0.62, 0.71), difference(
    cube(20, center: true),
    sphere(12, fn: 64),
    ..((0, 0, 0), (90, 0, 0), (0, 90, 0)).map(r => rotate(r, bore)),
  )),
  smooth-normals: 25,
  azimuth: 32,
  elevation: 24,
  up: (0, 1, 0),
  specular: 0.35,
  antialias: 3,
  background: none,
)
```

</td>
<td><img src="https://raw.githubusercontent.com/bernsteining/maquette/maquette-scad-v0.1.0/examples/readme/scad-dsl.png" width="300" alt="CSG cube built with the Typst DSL" /></td>
</tr>
<tr><th colspan="2" align="left">3. Multiple OpenSCAD files</th></tr>
<tr>
<td>

```typst
#import "@preview/maquette-scad:0.1.0": *

#render-scad-tree(
  "Cyclone.scad",
  root: "cyclone-src/",
  read: p => read(p),
  ..openscad-view,
  azimuth: 35,
  elevation: 20,
  up: (0, 0, 1),
  background: none,
)
```

</td>
<td><img src="https://raw.githubusercontent.com/bernsteining/maquette/maquette-scad-v0.1.0/docs/cyclone-example.png" width="300" alt="Cyclone-PCB-Factory CNC mill, a full multi-file OpenSCAD project" /></td>
</tr>
</table>

The Cyclone example is the [Cyclone-PCB-Factory](https://github.com/carlosgs/Cyclone-PCB-Factory).

## Documentation

* [docs/maquette-scad-documentation.pdf](https://github.com/bernsteining/maquette/blob/maquette-scad-v0.1.0/docs/maquette-scad-documentation.pdf) 

