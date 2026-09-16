# Arch-Plotter

**Arch-Plotter** is a powerful, parametric 2D CAD and land surveying engine built for [Typst](https://typst.app/) and powered by [CeTZ](https://github.com/cetz-package/cetz). 

Whether you are drafting interior floor plans with dynamic walls and furniture, or generating legally accurate surveying documents with automatic area calculations and peg schedules, Arch-Plotter handles the complex geometry so you can focus on drafting.

[📖 Read the Reference Manual to get started (PDF)](Manual.pdf)

## Features
* **Two Distinct Engines:** A dedicated toolset for Architecture (buildings/interiors) and Plotting (land surveying/subdivisions).
* **Parametric Drafting:** Draw using standard CAD commands (`R`, `L`, `U`, `D`, `mark`, `jump`) without needing to calculate raw coordinates.
* **Auto-Documentation:** Instantly generate Perimeter/Area schedules and X/Y Corner Coordinate tables directly from your drawings.
* **Layer System:** Draw structural boundaries, dashed setbacks, and utility easements in a single pass.
* **Smart Components:** Drop in scalable, rotatable parametric furniture (beds, gas burners, washbasins, etc.).

---

## 🚀 Quick Start

To avoid namespace collisions between the interior drafting tools and the land surveying tools, **Arch-Plotter uses scoped imports.** Import the canvas wrapper and core tools from the main package, and you are ready to start drafting.

### Example 1: Comprehensive Architectural Floorplan
This example demonstrates the full power of the continuous tracing engine, smart components, and automatic documentation tools.
```typst
// 1. Setup the page and import the package, the Plotter will automatically imported as p
#import "@preview/arch-plotter:0.1.0": *
#set page(width: auto, height: auto, margin: 1.0cm,)

// Quick aliases for true/false parameters
#let t = true
#let f = false

#set text(size: 1.4em)

// Initialize the CAD canvas with a 0.6cm scale
#arch-canvas(scale: 0.6cm,{

// 2. Define standard dimensions (Width, Height, Wall Thicknesses)
let w = 28
let h = 25
let nine = (9/12)     // 9-inch outer walls
let four = (4.5/12)   // 4.5-inch partition walls

  
// 3. TRACE THE WALLS
// Using CAD commands to draw the perimeter and internal walls, saving marks along the way
let wall = trace-walls(start: (0,0), align:"left", thickness:nine, 

(R(w,), mark("w1"), // Move Right, save corner 1
U(h,), mark("w2"),  // Move Up, save corner 2
L(w,), mark("w3"),  // Move Left, save corner 3
C(),                // Close boundary

home(),             // Return to start without drawing

JU(h/2,), mark("pillar1"), // Jump Up to mid-wall
JR(w), mark("pillar2"),    // Jump Right to opposite mid-wall

home(),

// Jump across to plot structural grid points
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

// Intersect lines dynamically using drop-x and drop-y tools
drop-x("c3", "c1", thickness:four), mark("b"),
drop-y("w3", "c6", thickness:four),

jump-to-mark("c3"),

drop-x("pillar2","w1"),
)
)

// 4. RENDER THE WALLS
draw-walls(wall,)

// Extract saved anchor coordinates for easy access
let w = wall.anchors

// 5. PLACE ARCHITECTURAL ELEMENTS
// Openings and columns placed exactly at our saved marks
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

// 6. ADD DIMENSIONS
dim(w.start, w.w3, size: 18pt, offset: 1)
dim(w.w3, w.w2, size: 18pt, offset: 1,)
dim(w.start, w.a, size: 14pt, offset: -3, shift: (nine,0))
dim(w.c2, w.w1, size: 14pt, offset: -0.5, shift: (0,nine))

// 7. DOORS & WINDOWS
door(w.b, w.c3, 2.2, thickness: four, align: "left", label: [#v(-2.5em)D], swing: "out")
window(w.w3, w.pillar1, 4, align: "left", width: 5, label: [#text(size: 11pt)[W]])

// 8. ROOM GENERATION
// Auto-labels "BED ROOM" and calculates boundaries based on marks
poly-room((w.w3, w.c5, w.b, w.a), [BED ROOM], fill: green.transparentize(94%), stroke: red+0pt, wall-widths: (-nine,-four, -four, -nine),  units: "imperial",)

ots((w.start, w.c1, w.b, w.a), show-dim: t, show-area: t, wall-widths: (nine, 0,0,nine))

// 9. STAIRS & EXTRA WINDOWS
stairs(move(w.c2, dx: 0.5, dy: 4), angle: 270deg, steps: (6,0,4), turn: "", split-landing: t)
window(w.a, w.b, 5, thickness: four, align: "left", width: 3, label: [W])
print-marks(wall)
opening(w.c3, w.c4, 4.5, thickness: nine, align: "left", width: 5)

// 10. PLOTTER ENGINE (LAND SURVEYING)
// Using the plotter module (p.) to draw an external boundary arc
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

// Connect the two plots with a curved boundary
p.draw-arc-to(ch1.anchors.ch1, ch2.anchors.ch2, 30, steps: 8,)

// 11. PARAMETRIC FURNITURE
dining-table(move(w.c4, dx: 2, dy: 4), label: [Dining table], scale: 3,size: (2,1), chairs: 6)
bed(move(w.w3, dx: 6, dy: -3.1), scale: 2, rotation: 270deg, size: "king", )

// 12. DRAW THE RULER BORDER
drafting-ruler(28,25, step: 1, )
})
```
