# Mesa: Usage Manual

A sample is built from bottom to top inside `layer-stack`. Mesa uses unitless
coordinates; the examples in this manual treat one unit as one nanometre.

```typ
#import "@preview/mesa:0.5.0" as semi

#let sample = {
  import semi: *

  layer(
    "substrate",
    thickness: 30,
    material: "substrate",
    label: [Si],
  )
  layer(
    "oxide",
    thickness: 5,
    material: "dielectric",
    label: [SiO#sub[2]],
  )
  layer(
    "gate",
    thickness: 15,
    material: "metal",
    label: [Al],
  )
}

#semi.layer-stack(sample)

#semi.layer-stack(
  sample,
  camera: (azimuth: 35deg, elevation: 25deg),
  shading: "fancy",
)
```

`layer-stack` wraps a CeTZ canvas. The functions in its body add layers to the
drawing in order. Other CeTZ components and primitives can be used in the body
to annotate the drawing. The same sample can be rendered from different
camera angles or as a cross-section simply by adjusting the related arguments.

## Layers

`layer` deposits material vertically over the complete sample or a mask.
`thickness` sets its thickness on upward-facing surfaces.

```typ
layer(
  name,
  thickness: none,
  mask: none,
  material: auto,
  sidewall-coverage: 0%,
  edge-profile: none,
  label: none,
)
```

- `name` identifies the layer and its anchors.
- `thickness` is required.
- `mask` accepts polygon geometry.
- `material` selects a palette family or supplies a customized material.
- `sidewall-coverage` sets the thickness on vertical surfaces as a percentage
  of `thickness`.
- `edge-profile` shapes the exposed upper edges of the deposited material.
- `label` accepts Typst content or a label dictionary.

Label dictionaries collect `draw.content` options around their content:

```typ
label: (
  content: [SiO#sub[2]],
  position: "front",
  project: auto,
  angle: 0deg,
  anchor: none,
  name: none,
)
```

Short positions and projection faces are relative to the layer: `"front"`
resolves to `"layer-name.front"`. By default, a label is projected onto the
centre of the layer's front face.

`sidewall-coverage: 0%` gives a directional deposition. Intermediate values
model partial sidewall coverage; `100%` gives the sidewalls the same thickness
as the top surface.

`edge-profile` describes physical edge geometry:

```typ
edge-profile: (
  size: 8%,
  profile: "round",
  facets: 6,
)
```

`size` accepts a number in units or a ratio of the layer thickness. `profile`
accepts `"chamfer"` or `"round"` and defaults to `"chamfer"`. A chamfer uses one
planar facet. A round profile approximates a quarter-circle with `facets`, which
defaults to `6`. The lower boundary follows the geometry supporting the layer.
Later depositions and etches use the resulting sloped surfaces.

`conformal-layer` coats every exposed surface, including downward-facing
surfaces, with equal thickness:

```typ
conformal-layer(
  "coating",
  thickness: 1,
  material: "dielectric",
)
```

`planar-layer` fills the selected area to one plane. `height` places that plane
relative to the substrate surface:

```typ
planar-layer(
  "resist",
  height: 20,
  material: "resist",
)
```

### Masks and process steps

```typ
gds(
  data,
  cell: none,
  layers: none,
  path-tolerance: 0,
  unit: auto,
  scale: 1,
  scale-x: 1,
  scale-y: 1,
  padding: 0,
)
```

```typ
#let layout = semi.gds(
  read("device.gds", encoding: none), // encoding: none is needed
  cell: "TOP", // cell name to read from the GDS file
  layers: (
    gate: (10, 0), // layer spec, i.e. 10/0
    metal: (20, 0),
  ),
  path-tolerance: 1%,
  unit: "nm",
  padding: (x: 100, y: 60),
)

#let sample = {
  import semi: *

  layer("substrate", thickness: 40, material: "substrate")
  layer("oxide", thickness: 5, material: "dielectric")
  layer("gate", thickness: 15, material: "metal", mask: layout.gate)
  etch(mask: layout.metal, layers: "oxide")
  layer("contacts", thickness: 10, material: "metal", mask: layout.metal)
}

#semi.layer-stack(sample, size: layout.size)
```

`gds` reads boundaries and width-aware paths from the selected flat cell. Paths
are converted to polygons.

Each entry in `layers` becomes a named mask, such as `layout.gate`.
`layout.size` contains the complete planar size and can be passed directly to
`layer-stack`.

`unit: auto` uses the user unit declared by the GDS file. `"nm"`, `"um"`/`"µm"`,
`"mm"`, `"cm"`, and `"m"` convert the layout to that unit; a positive number
specifies the unit size in metres. Layer thicknesses and etch depths use the
selected unit.

`scale` rescales both planar axes. `scale-x` and `scale-y` can compress them
independently while leaving vertical dimensions unchanged.

`padding` extends the layout around its masks. A number applies to every side,
`(x: 100, y: 60)` applies symmetric padding per axis, and
`(left: 50, right: 100, front: 30, back: 60)` controls each side.
`layout.size` includes this padding.

`path-tolerance` simplifies path centrelines before their widths are applied.
A ratio is relative to the path width; `0` preserves every vertex.

`semi.debug.gds(data)` lists the library units, cells, and layers.

`layer(..., mask:)` deposits over the selected polygons.

```typ
etch(
  depth: auto,
  mask: none,
  layers: auto,
  isotropic: 0%,
  sidewall: none,
)
```

`etch` removes exposed material through its mask. `layers` specifies which
layers should be affected by the etch, either as a single name or as an array of
layer names; `auto` means a non-selective etch of every layer. Unselected layers
remain untouched and stop the etch locally. `depth: auto` removes accessible
selected material down to the first blocking layer, or down to the substrate
if unspecified. A numeric depth limits the removal and may continue into the
substrate to create trenches.

The default etch is perfectly directional with 90° sidewalls. `isotropic` sets
the lateral etch rate relative to the vertical rate. `100%` produces a circular
profile, while intermediate percentages produce an elliptical profile. A
straight anisotropic sidewall angle can instead be specified directly:

```typ
etch(
  depth: 10,
  mask: opening,
  layers: "oxide",
  sidewall: 82deg,
)
```

`90deg` is vertical, a smaller angle narrows the opening with depth, and a
larger angle produces a re-entrant wall. With `depth: auto`, the distance to the
first stopping surface determines the vertical etch distance and therefore the
lateral distance set by `isotropic`, or the sidewall depth.
An isotropic etch can propagate laterally around the edge of a zero-rate layer,
so that layer remains in place without casting an anisotropic shadow beneath it.
`isotropic` and `sidewall` describe different etch models and cannot be
combined. Later commands build on the etched sample.

`mask: none` covers the complete sample. `semi.mask.invert(geometry)` selects
the geometric complement within the sample bounds.
`semi.mask.merge(geometry)` unions overlapping polygons into a normalized
mask. `semi.mask.difference(subject, geometry)` subtracts one mask from another.

To remove layers completely regardless of its geometry, `remove` can be used:

```typ
remove("resist")
remove(("resist", "sacrificial-oxide"))
```

It ignores any physical constraint: masks, blockers, or depth. Use it for an ideal
strip, lift-off, or other step where the named material should just disappear
completely.

### Materials

Materials set the fill, outline, pattern, fade, and other visual properties of
a layer. `semi.default-palette` contains `default`, `substrate`, `dielectric`,
`metal`, and `resist` families. `material: auto` uses `default`. Repeated layers
cycle through the variants in their material family.

A material dictionary selects a family and collects its variant and local
overrides:

```typ
material: (
  family: "substrate",
  variant: auto,
  fill: rgb("#b9cbd0"),
  stroke: .55pt,
  internal-stroke: none,
  edge-accent-stroke: auto,
  edge-accent: auto,
  fade-bottom: (start: 70%, end: 95%, color: white),
)
```

The active palette supplies the selected family and variant. The remaining
entries override that material for this layer. `stroke`, `internal-stroke`, and
`edge-accent-stroke` style the layer's edges; the *Rendering* section explains
how a material entry, the stack value, and the palette combine.

`fill` accepts a color or a `hatch`, `crosshatch`, or `dots` tiling:

```typ
layer(
  "metal",
  thickness: 10,
  material: (
    family: "metal",
    fill: hatch(
      background: rgb("#d8c27a"),
      color: rgb("#8e762c"),
    ),
  ),
)
```

The alpha channel of a color makes the layer transparent. 

`fade-bottom` fades a material between two depths measured from its top:

```typ
material: (
  family: "substrate",
  fade-bottom: (start: 70%, end: 95%, color: white),
)
```

The default substrate style uses this fade.

`palette` customizes material defaults for a stack. A family may contain one
style or an array of variants:

```typ
#semi.layer-stack(
  sample,
  palette: (
    metal: (
      (fill: rgb("#d9b44a")),
      (fill: rgb("#d7a17c")),
    ),
  ),
)
```

### Anchors and content

Every layer defines CeTZ anchors for its faces, edges, and corners:

```typ
"metal.front"
"metal.top"
"metal.back-right"
"metal.back-right-bottom"
```

These anchors work wherever CeTZ accepts a coordinate.

Mesa's `draw` module re-exports CeTZ drawing functions. Its `content` function
adds face projection:

```typ
draw.content(
  position,
  body,
  project: auto,
  angle: 0deg,
  anchor: none,
  name: none,
)
```

`project: auto` uses the face named by a central face coordinate:

```typ
draw.content("resist.front", [Photoresist])
```

Placement and projection may refer to separate nodes:

```typ
draw.content(
  "metal-t.mid",
  text(7pt)[15 nm],
  project: "metal.back",
  anchor: "west",
)
```

`project: none` keeps the content in page coordinates. The central `front`,
`back`, `left`, and `right` anchors use the visible centre of a fading layer.

## Rendering

```typ
layer-stack(
  body,
  size: (80, 50),
  camera: (
    azimuth: 0deg,
    elevation: 0deg,
  ),
  shading: "flat",
  light: (
    azimuth: -45deg,
    elevation: 60deg,
    intensity: 0.25,
  ),
  crease-angle: 15deg,
  palette: (:),
  edge-accent: auto,
  stroke: auto,
  internal-stroke: auto,
  edge-accent-stroke: auto,
  length: .8mm,
  baseline: none,
  background: none,
  padding: none,
  cut: none,
  section: none,
  debug: none,
  canvas-debug: false,
)
```

`size` is `(x-width, y-depth)`. `length` sets the rendered length of one unit
and defaults to `.8mm`.

### Coordinates and camera

Mesa uses a right-handed device coordinate system:

- `x`: width;
- `y`: depth;
- `z`: height.

The substrate lies in the `x-y` plane. The default camera shows the front
`x-z` cross-section. Camera azimuth rotates around `z`; elevation moves above
the substrate. Positive azimuth reveals the right face, and positive elevation
reveals the top.

Face names remain fixed in model space:

- `"front"`: `y = 0`;
- `"back"`: `y = depth`;
- `"left"`: `x = 0`;
- `"right"`: `x = width`.

### Light and shading

Light angles describe the direction in which light travels. Azimuth `0deg`
travels along `+y`; positive azimuth rotates toward `+x`. Elevation `0deg`
lies in the `x-y` plane; positive elevation makes the light source appear higher.
`intensity` accepts a number from `0` to `1` or an equivalent ratio and controls
the contrast between faces oriented toward and away from the light.

`shading` selects the rendering style:

- `"none"` preserves the colours and patterns defined by each material;
- `"flat"` shades each face according to its orientation;
- `"fancy"` adds cast shadows, giving patterned structures a stronger sense
  of depth.

In fancy shading, patterned features can cast shadows onto the layers beneath
them and onto other parts of the same layer.

`edge-accent` adds a cosmetic bevel to each layer:

```typ
edge-accent: (top: 0.5, bottom: 0.2)
edge-accent: (top: 2.5%, bottom: 0%) // relative to layer thickness
```

An edge-accent value accepts numbers in units or ratios of the layer thickness.
It changes the rendered edge without changing the geometry used by later
process steps.

`crease-angle` sets the largest join whose crease stroke is omitted. At `0deg`,
only coplanar faces are joined. Higher values clean up the outlines of curves
represented by many short polygon segments.

`stroke`, `internal-stroke`, and `edge-accent-stroke` style the edges Mesa
draws. `stroke` is the exterior outline and the boundaries between materials,
`internal-stroke` the inside corners between the pieces of a single layer, and
`edge-accent-stroke` the contours of an edge accent.

These styles and `edge-accent` resolve the same way. The most specific setting
wins: a per-layer material dictionary first, then the stack value here, then
the material's palette entry. `auto`, the default at every level, defers to the
next. If every `edge-accent` setting defers, no accent is drawn.

An edge accent is drawn for looks rather than built by the process, so its
contours are kept apart from the device's own edges. Physical geometry,
`edge-profile` facets included, is not affected: those are ordinary surfaces and
their edges follow `crease-angle` like any other.

### Cross-sections and cuts

`section` renders a cross-section of the sample through the specified plane:

```typ
section: ((0, 25), (80, 25))
```

`cut` splits the three-dimensional sample across the plane and renders the selected side:

```typ
cut: ((0, 25), (80, 25))
cut: (plane: ((0, 25), (80, 25)), keep: "right")
```

The line form keeps its left side. The dictionary form accepts `"left"` or
`"right"`.

All planes are defined as (point, direction) and are "vertical" planes,
i.e. they can only run along the `z` axis.

### Debugging

`debug: true` replaces the render with a diagnostic view of it. The 3D render
becomes a topology view; a cross-section becomes a pieces view.

The topology view redraws the 3D image with its edges classified into exterior
outlines, material boundaries, internal edges, edge accents, occluded edges, and
the smooth edges left undrawn. It follows the stack's `crease-angle`. The pieces
view draws a cross-section with each layer drawn one piece at a time,
distinguishing the exterior outline, the internal edges between a layer's pieces,
and every vertex.

`semi.debug.topology(body, ..layer-stack-arguments)` and
`semi.debug.section(body, section: plane, ..layer-stack-arguments)` are these
two views with a legend attached. Both take the same arguments as `layer-stack`.

In addition to `true`, `debug` accepts overlays to draw over the 3D render:

```typ
#semi.layer-stack(
  sample,
  debug: {
    import semi.debug: *

    axes()
    light()
    face-info(
      faces: ("front", "right"),
      layers: "resist",
      values: ("cosine", "visibility", "brightness"),
    )
    normals(faces: "top", layers: "resist")
  },
)
```

- `axes()` draws the device coordinate axes.
- `light()` draws the light direction, angular construction, and intensity.
- `face-info()` places lighting-related values on selected faces.
- `normals()` draws the normal vector to each selected surface.

`faces: auto` selects camera-visible side faces. `layers` filters by layer name.
For `face-info`, `cosine` measures how directly a face points toward the light,
`visibility` shows whether the light reaches it (as a binary number, either 1 or 0),
and `brightness` is the final shading value. These overlays apply to the 3D
render only, not to a cross-section.

`semi.debug.gds(data)` lists the units, cells, and layers in a GDS file.

### Canvas

`length`, `baseline`, `background`, and `padding` pass through to `cetz.canvas`.
`canvas-debug` shows CeTZ's bounding-box debugger.
