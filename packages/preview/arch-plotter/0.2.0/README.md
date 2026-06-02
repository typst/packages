# Arch-Plotter

**Arch-Plotter** is a powerful, parametric 2D CAD and land surveying engine built for [Typst](https://typst.app/) and powered by [CeTZ](https://github.com/cetz-package/cetz). 

Whether you are drafting interior floor plans with dynamic walls and furniture, or generating legally accurate surveying documents with automatic area calculations and peg schedules, Arch-Plotter handles the complex geometry so you can focus on drafting.

[📖 Read the Reference Manual to get started (PDF)](Manual.pdf)

## Features
* **Two Distinct Engines:** A dedicated toolset for Architecture (buildings/interiors) and Plotting (land surveying/subdivisions).
* **Parametric Drafting:** Draw using standard CAD commands (`r`, `l`, `u`, `d`, `mark`, `jump`) without needing to calculate raw coordinates.
* **Auto-Documentation:** Instantly generate Perimeter/Area schedules and X/Y Corner Coordinate tables directly from your drawings.
* **Layer System:** Draw structural boundaries, dashed setbacks, and utility easements in a single pass.
* **Smart Components:** Drop in scalable, rotatable parametric furniture (beds, gas burners, washbasins, etc.).
* **Instant 3D Extrusion (New in v0.2.0):** Automatically turn your 2D floor plans into fully rotatable 3D models. Features a built-in painter's algorithm (Z-sorting), physical sun-shading, ambient occlusion gradients, and translucent glass shaders.

---

# Changelog

## [arch-plotter version - 0.2.0]

### 🚀 Major Features & Additions
* **3D Architecture Engine (`draw-3d-walls`):** Introduced a native 3D isometric rendering engine. Extrudes 2D floor plans into 3D models with camera controls (`spin`, `pitch`), canvas placement (`position`, `scale`), and dynamic shading (`roof-lighten`, `shadow-darken`, `glass-color`).
* **Pure Mathematical 2D Wall Engine:** Completely rewrote `draw-walls`. It now uses an epsilon-safe mathematical intersection engine to compute perfect miter joints, completely eliminating the need for visual masking tricks.
* **Universal CAD Raycaster:** The `trace-walls` engine can now cast rays! You can pass `"auto"`, a percentage (e.g., `50%`), or the name of an existing anchor as a movement distance, and the engine will automatically calculate the intersection and snap to it.
* **Architectural Auto-Dimensions Router (`draw-auto-dims`):** A powerful new routing engine that automatically dimensions perimeters and point-chains. Includes advanced filtering (`hide`, `display`), offset management, and style overrides per dimension.
* **Advanced Dimension Suite:** Replaced the basic `dim` function with a robust suite including `dim-x`, `dim-y`, and `dim-chain`. Introduced `ext-lines` that mathematically drop down to the exact intersection of the wall geometry.

### 🚪 Component Upgrades
* **Parametric Door Styles:** The `opening` component received a massive overhaul. It now supports highly complex parametric styles: `"sliding"` (bypass), `"surface-sliding"` (barn door), `"bifold"` (single and double), and `"pocket"` doors.
* **Door States:** Added `open` (0.0 to 1.0) to physically slide or fold the new door styles, and `flip` to reverse the mounting/sliding direction.
* **Inline Trace Components:** Added `t-door`, `t-double-door`, `t-window`, and `t-opening`. You can now drop components directly into the `trace-walls` operation list rather than placing them manually afterward.
* **Refined Glazing:** `window` components now draw a complete outer frame (`stroke: 1pt`) and hollow interior for much cleaner blueprint legibility.

### 📐 Tracing Engine Enhancements
* **Auto-Marking System:** Added `mark-steps` to `trace-walls`. When enabled, it automatically logs anchors for every wall (`w1`, `w2`, etc.), every jump (`j1`), and automatically detects and logs all wall intersections.
* **Midpoint Snapping:** Added `jump-to-mid` and `go-to-mid` commands to automatically calculate and route the pen to the center of any two coordinates or anchors.
* **Hidden Zones:** Added `hide-between(p1, p2)` to the tracing commands. The new wall engine will mathematically calculate and erase any wall geometry that falls strictly between those two points.
* **Skew Overrides:** Added `skew-start` and `skew-end` to tracing operations, allowing users to manually override the automatic miter-joint extensions.

### 🛠 Improvements & Refactoring
* **Dependency Bump:** Upgraded from CeTZ `0.4.2` to CeTZ `0.5.2`.
* **Spatial Grouping for Marks:** Upgraded `print-marks` with a spatial grouping engine. If multiple anchors occupy the exact same physical space (down to 3 decimal places), it gracefully merges them into a single comma-separated label to prevent text overlapping.
* **Debug Mode:** Added `debug: true` to `draw-walls`. When enabled, it overlays a forensic view of the floor plan, showing wall lengths, thicknesses, alignments, and rendering intersection nodes.
* **Modularization:** Moved helper math into `Arch-helper.typ` and extracted hatch patterns (`bricks-fill`, `grass-fill`, `hatch-fill`) into their own dedicated `Hatches.typ` module to keep the main library clean.

### 🐛 Bug Fixes
* **Column Crash:** Fixed a geometry crash in the `column()` component where passing `sides` less than 3 would break the math. It now safely defaults to 4 (square) if invalid data is passed.
* **Component Rendering Order:** The new wall engine processes openings and walls simultaneously, fixing previous issues where visual masking would break on overlapping corners.

## 🚀 Quick Start

To avoid namespace collisions between the interior drafting tools and the land surveying tools, **Arch-Plotter uses scoped imports.** Import the canvas wrapper and core tools from the main package, and you are ready to start drafting.

### Example 1: Architectural Floorplan
Use the continuous tracing engine to draw walls, and effortlessly drop parametric doors and windows into your design.

```typst
#import "@preview/arch-plotter:0.2.0": *
#set page(width: auto, height: auto, margin: 1.0cm,)

#let t = true

#let f = false

#set text(size: 1.4em)


#arch-canvas(scale: 0.6cm,{

let w = 28
let h = 25
let nine = (9/12)
let four = (4.5/12)

  
let wall = trace-walls(start: (0,0), align:"left", thickness:nine, 

(R(w,), mark("w1"),

U(h,), mark("w2"),

L(w,), mark("w3"),

C(),

home(),

JU(h/2,), mark("pillar1"),

JR(w), mark("pillar2"),

home(),

JR(w/3), mark("c1"),

JR(w/3), mark("c2"),

jump-to-mark("pillar1"),

JR(w/3), mark("c3"),

JR(w/3), mark("c4"),

jump-to-mark("w3"),

JR(w/3),

mark("c5"),

JR(w/3), mark("c6"),

jump-to-mark("pillar1"),

jump-to-mark("pillar1"), 

JD(3+(8.5/12)), mark("a"),

drop-x("c3", "c1", thickness:four), mark("b"),

drop-y("w3", "c6", thickness:four),

jump-to-mark("c3"),

drop-x("pillar2","w1"),

)
)

draw-walls(wall,)

let w = wall.anchors

opening(w.c2, w.c1, 5.05, width: 8.5, align: "right", label: [GATE])

column(w.start, align: "left", shift: (four,0),  size: nine, sides: 30,)

column(w.w1, align: "left", shift: (-four,0))

column(w.w2, align: "left", shift: (-four,-nine))

column(w.w3, align: "left", shift: (four,-nine))

column(w.pillar1, align: "left", shift: (four,0))

column(w.pillar2, align: "left", shift: (-four,0))

column(w.c1, align: "left", shift: (-four,0))

column(w.c2, align: "left", shift: (-four,0))

column(w.c3, align: "left", shift: (-four,0))

column(w.c4, align: "left", shift: (-four,0))

column(w.c5, align: "left", shift: (-four,-nine))

column(w.c6, align: "left", shift: (-four,-nine))

dim(w.start, w.w3, size: 18pt, offset: 1)

dim(w.w3, w.w2, size: 18pt, offset: 1,)


dim(w.start, w.a, size: 14pt, offset: -3, shift: (nine,0))

dim(w.c2, w.w1, size: 14pt, offset: -0.5, shift: (0,nine))

door(w.b, w.c3, 2.2, thickness: four, align: "left", label: [#v(-2.5em)D], swing: "out")

window(w.w3, w.pillar1, 4, align: "left", width: 5, label: [#text(size: 11pt)[W]])

poly-room((w.w3, w.c5, w.b, w.a), [BED ROOM], fill: green.transparentize(94%), stroke: red+0pt, wall-widths: (-nine,-four, -four, -nine),  units: "imperial",)

ots((w.start, w.c1, w.b, w.a), show-dim: t, show-area: t, wall-widths: (nine, 0,0,nine))

stairs(move(w.c2, dx: 0.5, dy: 4), angle: 270deg, steps: (6,0,4), turn: "", split-landing: t)

window(w.a, w.b, 5, thickness: four, align: "left", width: 3, label: [W])

print-marks(wall)


opening(w.c3, w.c4, 4.5, thickness: nine, align: "left", width: 5)


let ch1 = p.trace-plot(start: (0,0), 
(p.D(1.5), p.R(2), p.D(1), p.Mark("ch1"),
p.JumpHome(),
p.JR(w.w1.at(0))
))

let ch2 = p.trace-plot(start: w.w1, 
(p.D(1.5), p.L(2), p.D(1), p.Mark("ch2")
))

p.draw-plot(ch1, close-path: f, show-area: f)

p.draw-plot(ch2, close-path: f, show-area: f)

p.draw-arc-to(ch1.anchors.ch1, ch2.anchors.ch2, 30, steps: 8,)

dining-table(move(w.c4, dx: 2, dy: 4), label: [Dining table], scale: 3,size: (2,1), chairs: 6)

bed(move(w.w3, dx: 6, dy: -3.1), scale: 2, rotation: 270deg, size: "king", )

drafting-ruler(28,25, step: 1, )
}) ```