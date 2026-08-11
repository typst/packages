#import "@preview/tidy:0.4.3"

#set page(paper: "a4", margin: 1in)
#set text(font: "Linux Libertine", size: 16pt)
#show raw: set text(font: ("Fira Code",))


#let arch-docs = tidy.parse-module(read("../src/Arch.typ"), old-syntax: true)

// 2. CONVERT the locked module into a mutable dictionary
#let custom-style = dictionary(tidy.styles.default)

// 3. The exact CeTZ color palette (fully expanded)
#let type-colors = (
  // Measurements & Numbers (Light Purple)
  "length":     rgb("#e7d9ff"),
  "angle":      rgb("#e7d9ff"),
  "number":     rgb("#e7d9ff"),
  "float":      rgb("#e7d9ff"),
  "int":        rgb("#e7d9ff"),
  "integer":    rgb("#e7d9ff"),
  "ratio":      rgb("#e7d9ff"),
  
  // Strings & Text (Mint Green)
  "string":     rgb("#d1ffe2"),
  "str":        rgb("#d1ffe2"),
  
  // Booleans (Light Yellow)
  "bool":       rgb("#ffedc1"),
  "boolean":    rgb("#ffedc1"),
  
  // Null / Auto (Light Peach/Red)
  "none":       rgb("#ffcbc4"),
  "auto":       rgb("#ffcbc4"),
  
  // Typst Content (Teal)
  "content":    rgb("#a6ebe6"),
  
  // Data Structures (Light Orange)
  "array":      rgb("#ffdfc4"),
  "dictionary": rgb("#ffdfc4"),
  
  // Geometry & Math (Light Blue)
  "coordinate": rgb("#c4e8ff"),
  "vector":     rgb("#c4e8ff"),
  
  // Styling properties (Light Pink/Magenta)
  "color":      rgb("#ffc4e8"),
  "stroke":     rgb("#ffc4e8"),
  
  // Functions (Soft Pink/Purple)
  "function":   rgb("#f9dfff"),
  
  // Default / Any (Light Grayish Blue)
  "any":        rgb("#eff0f3"), 
)

// FOOLPROOF TYPE EXTRACTOR
#let get-types(info) = {
  let t = info.at("types", default: none)
  if type(t) == array and t.len() > 0 { return t }
  if type(t) == str and t != "" { return (t,) }
  
  let t2 = info.at("type", default: none)
  if type(t2) == array and t2.len() > 0 { return t2 }
  if type(t2) == str and t2 != "" { return (t2,) }
  
  return ("any",) 
}

#let my-show-type(type-name, style-args: none, ..kwargs) = {
  let types = type-name.split(regex("[,|]")).map(t => t.trim())
  
  let boxes = types.map(name => {
    box(
      raw(name), 
      inset: 2pt, baseline: 2pt, radius: 2pt,
      fill: type-colors.at(name, default: type-colors.at("any")), 
      stroke: none
    )
  })
  
  boxes.join(h(4pt))
}

#let my-show-signature(fn, style-args: none, ..kwargs) = {
  let args-list = ()
  for (name, info) in fn.args {
    let t-array = get-types(info)
    let t-str = my-show-type(t-array.join(" | "), style-args: style-args)
    args-list.push([#h(1em)#raw(name + ":") #t-str])
  }
  
  let return-str = if "return-types" in fn and fn.return-types != none {
    [ #sym.arrow.r #my-show-type(fn.return-types.join(" | "), style-args: style-args) ]
  } else { none }

  block(spacing: 0.6em)[
    #set par(leading: 0.35em)
    #text(blue, raw(fn.name))#raw("(")
    #if args-list.len() > 0 [
      \ #args-list.join([,\ ]) \
    ]
    #raw(")") #return-str
  ]
}

#let my-show-parameter-list(fn, style-args: none, ..kwargs) = {
  if fn.args.len() == 0 { return none }
  
  block(spacing: 1.5em)[
    #text(weight: "bold", size: 1.1em)[Parameters]
    
    #for (name, info) in fn.args [
      #let t-array = get-types(info)
      #let type-content = my-show-type(t-array.join(" | "), style-args: style-args)
      
      - *#raw(name)* #type-content \
        #info.at("description", default: "")
    ]
  ]
}

#let my-show-routine(fn, style-args: none, ..kwargs) = {
  let h-level = if type(style-args) == dictionary {
    style-args.at("first-heading-level", default: 2)
  } else { 2 }

  heading(level: h-level, fn.name)
  v(0.3em)
  my-show-signature(fn, style-args: style-args)
  v(1em)
  
  if fn.description != none [
    #fn.description
    #v(1em)
  ]
  
  my-show-parameter-list(fn, style-args: style-args)
  v(2em)
}

#{
  custom-style.show-type = my-show-type
  custom-style.show-signature = my-show-signature
  custom-style.show-parameter-list = my-show-parameter-list
  custom-style.show-routine = my-show-routine
  custom-style.show-function = my-show-routine
}

#align(center)[
  #text(size: 24pt, weight: "bold")[Arch-Plotter Reference Manual] \
  #v(1em)
  Auto-generated Documentation by using tidy library

  Version 0.1.0
]

#v(2em)
#columns(2)[
#outline()]
#pagebreak()


= Introduction & Setup
The `Arch.typ` engine is designed to rapidly draft floor plans, generate dynamic walls with clean intersections, and drop in parametric architectural components (doors, windows, stairs, furniture) using intuitive commands.

To use the Architecture engine, import the `arch-canvas` wrapper from the main library, and then import the `Arch.typ` module directly from the `src/` folder to access the shorthand commands without prefixes.

```typ
#import "@preview/arch-plotter:0.1.0": *

#arch-canvas(scale: 0.5cm, {
  // Your drafting code here
})```

= Unit Systems
The engine operates natively in Decimal Feet. However, helper functions are provided so you can draft using standard Architectural notation or Metric units.

```typc ft(feet, inches)```: Converts feet and inches to decimal feet. E.g., ft(5, 6) returns 5.5.

m(meters): Converts meters to decimal feet. E.g., m(2) returns 6.56.

cm(centimeters): Converts centimeters to decimal feet.

Formatting Distances:
Use format-dist(value, unit-system: "imperial") or unit-system: "metric" to automatically format raw numbers into beautiful text (e.g., 5'6 1/2" or 1.5 m).

= Tracing Walls
The core of the Architecture engine is the trace-walls() function. It acts like a continuous pen on paper.

Code snippet

```typc 
let house = trace-walls(start: (0,0), (
  R(20), U(15), L(20), C()
))
draw-walls(house, default-thickness: 0.75)```
== Movement Commands

R(len) / L(len): Move Right / Left.

U(len) / D(len): Move Up / Down.

A(angle, len): Move at a specific angle.

DropX(p1, p2) / DropY(p1, p2): Raycast your current line horizontally or vertically until it intersects with a target boundary (like an angled wall).

C() or Home(): Close the shape back to the start.

== Jumps & Marks (Lifting the Pen)
If you need to move the cursor without drawing a wall, use Jump commands:

JR(len), JL(len), JU(len), JD(len): Jump Right, Left, Up, Down.

JA(angle, len): Jump at an angle.

Mark("name"): Save the current coordinate in the engine's memory.

GoToMark("name"): Draw a wall directly to a saved mark.

JumpToMark("name"): Lift the pen and teleport to a saved mark.

= Architectural Components
Components snap relative to the coordinates you trace.

== Doors and Openings

Code snippet
```typc door(from, to, dist, width: 3.0, hinge: "left", swing: "in")
double-door(from, to, dist, width: 6.0, swing: "out")
opening(from, to, dist, width: 4.0, style: "cross")```
from, to: The two coordinates representing the wall segment.

dist: How far along that wall (from the from point) to place the door.

hinge / swing: Controls the exact open position of the door leaf.

== Windows

Code snippet
window(from, to, dist, width: 4.0, thickness: 0.75)
Automatically erases the wall behind it and draws the glass panes and frame caps.

== Stairs

Code snippet
stairs((10, 10), steps: (5, 5), width: 3.0, run: 0.75, turn: "right")
Generates a parametric staircase.

steps: Can be a single integer (e.g., 12) for straight stairs, or an array (e.g., (5, 5)) to automatically insert landings.

turn: "left" or "right" determines which way the landing rotates.

== Columns

Code snippet
column((5, 5), size: 1.0, sides: 4) // Square
column((10, 5), size: 1.0, sides: 30) // Circle
= Smart Rooms & O.T.S.
If you don't want to manually trace every wall, you can pass an array of coordinates to generate instant spaces.

Code snippet

```typc
let pts = ((0,0), (10,0), (10,10), (0,10))
poly-room(pts, "Master Bed", wall-widths: (0.75,), show-dim: true, show-area: true)
ots(pts, name: "Shaft")```

wall-widths: Pass an array of thicknesses. The engine will automatically calculate the complex inset geometry, shift the walls inward, and calculate the true internal area.

= Drafting Utilities

```typc dim(from, to): Standard external dimension line.

i-dim(from, to): Internal dimension line (automatically shrinks to fit between wall thicknesses).

callout(target, text-pos, label): Draws a leader line with a shoulder to point at specific details.

drafting-grid(width, height): Overlays a faint measurement grid.

drafting-ruler(width, height)```: Draws CAD-style coordinate rulers on the left and top edges.

= Architectural Components

Components are designed to snap seamlessly to your traced walls. For components that attach to a wall (like doors and windows), you provide the `from` and `to` coordinates of the wall segment, and the `dist` (distance) from the start point to place the component.

== `door()`
Places a parametric single door along a wall segment. It automatically calculates rotation and draws the door frame, leaf, and swing arc.

*Parameters:*
- `from` (_coordinate_): The starting point of the wall segment (e.g., `(0,0)`).
- `to` (_coordinate_): The ending point of the wall segment.
- `dist` (_float_): Distance from the `from` point to the center of the door.
- `width` (_float_) - Default: `3.0`: The width of the door opening.
- `hinge` (_string_) - Default: `"left"`: Which side the hinge is on. Values: `"left"`, `"right"`.
- `swing` (_string_) - Default: `"in"`: Which way the door opens. Values: `"in"`, `"out"`.
- `open` (_angle_) - Default: `90deg`: The angle the door leaf is open.
- `thickness` (_float_) - Default: `0.75`: Thickness of the wall to match.
- `label` (_content_) - Default: `none`: Optional text to display on the door.

*Example:*
```typc
door((0,0), (10,0), 5.0, width: 3.0, hinge: "right", swing: "out")```


== double-door()
Places a double-leaf door. Functions identically to door(), but splits the width into two sweeping arcs.

Parameters:

Shares all parameters with door() except hinge (as it has hinges on both sides).

== window()
Places a window along a wall. It automatically erases the wall lines behind it and draws the glass panes and frame caps.

Parameters:

wall-start _(coordinate)_: The starting point of the wall.

wall-end _(coordinate)_: The ending point of the wall.

dist _(float)_: Distance from the start point to the center of the window.

width _(float)_ - Default: 1.0: The width of the window.

thickness _(float)_ - Default: 0.75: The thickness of the wall.

label _(string|content)_ - Default: none: Optional text (e.g., "W1").

label-offset _(float)_ - Default: 0.8: Distance to shift the label away from the glass.

Example:


```typc window((0,0), (0,10), 5.0, width: 4.0, label: "W-1")```
== opening()
Creates a cased opening or pass-through in a wall without a door leaf.

Parameters:

from, to, dist, width, thickness: Same as door().

style (string) - Default: "empty": The visual style of the opening. Values: "empty", "line", "rect", "cross" (often used for shafts or hidden lines).

== stairs()
Generates a parametric staircase. Can create straight runs, L-shapes, or U-shapes automatically based on the turns array.

Parameters:

pos (coordinate): The starting bottom-left coordinate of the stairs.

steps (int | array) - Default: 12: The number of treads. If an array is passed (e.g., (5, 5)), it automatically generates a landing between the runs.

width (float) - Default: 3.0: The width of the staircase.

run (float) - Default: 0.75: The depth of each individual tread.

angle (angle) - Default: 0deg: The global rotation of the entire staircase.

turn (string | array) - Default: "right": The direction the landing turns. Values: "right", "left".

split-landing (boolean) - Default: false: If true, draws a diagonal line across the landing to indicate a winder step.

Example:

Code snippet
stairs((10, 10), steps: (6, 6), turn: "left", width: 3.5)
== column()
Draws a structural column (square, circular, or polygonal).

Parameters:

pos (coordinate): The center or edge coordinate of the column.

size (float) - Default: 0.75: The overall width/diameter.

sides (int) - Default: 4: Number of sides. 4 = Square, 6 = Hexagon, 30+ = Perfect Circle.



= Smart Rooms & Zones

== poly-room()
Generates a complete, dimensioned room from a set of perimeter points. If wall widths are provided, it automatically calculates the complex inset geometry and shrinks the inner area.

Parameters:

pts (array): An array of coordinates (e.g., ((0,0), (10,0), (10,10), (0,10))).

name (string): The room label (e.g., "Master Bedroom").

wall-widths (array|none) - Default: none: An array of wall thicknesses. E.g., (0.75, 0.5).

show-area (boolean) - Default: true: Displays the calculated square footage.

show-dim (boolean) - Default: true: Displays the overall Width x Height.

units (string) - Default: "imperial": Formatting system. Values: "imperial", "metric".

== ots() (Open To Sky / Shaft)
Draws a designated shaft or open area with a standard architectural "X" crossed through it.

Parameters:

Shares parameters with poly-room(), but defaults show-area and show-dim to false.

#pagebreak()

= Land Surveying Engine (Plotter module)

The Plotter engine uses the exact same tracing logic as the Architecture engine, but is optimized for massive coordinates, angle properties, layer management, and CAD schedules.

== trace-plot()
Traces a property boundary. Uses the exact same movement commands (R, L, U, D, Mark, etc.) as trace-walls.

Special Plotter Command:

Layer("name"): Switches the active drawing layer. Any lines drawn after this command are visual only and are ignored by the Area and Perimeter calculators.

== draw-plot()
Renders the output of trace-plot with survey-specific visual data.

Parameters:

plot-data (dictionary): The data returned from trace-plot.

name (string) - Default: "": The plot identifier (e.g., "Plot 12").

show-dim (boolean) - Default: false: Automatically dimension every side of the boundary.

show-area (boolean) - Default: false: Calculate and display the total area inside the boundary.

show-angle (array) - Default: (false, false): (show-boolean, flip-boolean). Calculates and draws internal degrees for every corner.

layer-styles (dictionary) - Default: (:): Defines the visual style for custom layers. E.g., ("Setbacks": (stroke: red, dash: "dashed")).

== Automated CAD Schedules

plot-summary-table(..plots):
Takes one or more trace dictionaries (or an array of subdivisions) and generates a formatted Typst table showing the Plot Name, Perimeter, and Total Area.

peg-schedule(plot-data):
Extracts every single turning point from the main boundary layer and generates a surveyor's Corner Coordinate table showing the exact Easting (X) and Northing (Y) coordinates for stakeout.


= Arch (API)

#tidy.show-module(
  arch-docs,
  style: custom-style, 
  show-outline: false
)
