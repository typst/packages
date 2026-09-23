# Mesa: Usage Manual

A sample is built from bottom to top inside `layer-stack`. Mesa uses unitless
coordinates; the examples in this manual treat one unit as one nanometre.

```typ
#import "@preview/mesa:0.2.0" as semi

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

```typ
layer(
  name,
  thickness: none,
  material: auto,
  variant: auto,
  label: none,
  label-position: "front",
  label-project: auto,
  label-angle: 0deg,
  label-anchor: none,
  label-name: none,
  bevel: auto,
  stroke: auto,
  internal-stroke: auto,
  mask: auto,
  ..style,
)
```

- `name` identifies the layer and its anchors.
- `thickness` is required.
- `material` selects a style family.
- `variant` selects a 1-based style variant.
- `label` accepts Typst content.
- `label-*` forwards to `draw.content`. Short positions and projection faces
  are relative to the layer: `"front"` resolves to `"layer-name.front"`.
- `bevel`, `stroke`, and `internal-stroke` override the stack defaults.
- `mask` accepts polygon geometry.
- `..style` overrides material properties for this layer.

By default, `label` is projected onto the centre of the layer's front face.

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
  etch(depth: 5, mask: layout.metal) // this modifies the previous layer
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
`etch(depth:, mask:)` is used alongside `layer` in a sample body. When it is
reached, it removes `depth` units from the current surface wherever the
mask is present. Later commands build on the etched sample. In the example,
five units are removed through `layout.metal` before the contacts are
deposited.

`mask: auto` covers the complete sample. `semi.mask.invert(geometry)` selects
the geometric complement within the sample bounds.
`semi.mask.merge(geometry)` unions overlapping polygons into a normalized
mask. `semi.mask.difference(subject, geometry)` subtracts one mask from another.

### Materials

Material styles set the fill, outline, pattern, and fade of a layer.
`semi.default-palette` contains `default`, `substrate`, `dielectric`, `metal`,
and `resist` families. `material: auto` uses `default`. Repeated layers cycle
through the variants in their material family.

`fill` accepts a color or a `hatch`, `crosshatch`, or `dots` tiling:

```typ
layer(
  "metal",
  thickness: 10,
  material: "metal",
  base-color: rgb("#d8c27a"),
  fill: hatch(
    background: rgb("#d8c27a"),
    color: rgb("#8e762c"),
  ),
)
```

For patterned fills, `base-color` sets the solid color used on bevel faces.
`fade-bottom` fades a material between two depths measured from its top:

```typ
fade-bottom: (start: 70%, end: 95%, color: white)
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
  bevel: (top: 0.5, bottom: 0.25),
  internal-stroke: none,
  crease-angle: 0deg,
  palette: (:),
  length: .8mm,
  baseline: none,
  background: none,
  stroke: auto,
  padding: none,
  cut: none,
  section: none,
  debug: none,
  canvas-debug: false,
)
```

`size` is `(x-width, y-depth)`. `length` sets the rendered length of one model
unit and defaults to `.8mm`.

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
- `"flat"` shades each face according to its orientation while keeping layer
  edges square;
- `"fancy"` adds bevelled edges and cast shadows, giving patterned structures
  a stronger sense of depth.

In fancy shading, patterned features can cast shadows onto the layers beneath
them and onto other parts of the same layer.

`bevel` accepts one number, one ratio, or separate top and bottom values:

```typ
bevel: 0.5
bevel: 8%
bevel: (top: 0.5, bottom: 0.25)
```

A number gives the bevel size in units; a ratio is relative to the layer
thickness. The dictionary form controls the top and bottom edges independently.
Fancy shading generates bevels.

`crease-angle` sets the largest join between adjacent faces that is treated as
smooth. At `0deg`, only coplanar faces are joined. Higher values smooth the
outlines of curves represented by many short polygon segments.

`stroke` supplies an exterior-outline default for the complete stack.
`stroke: auto` preserves each material's stroke. A layer-level `stroke`
overrides the stack value, which in turn overrides the material. `none`
removes the corresponding outlines.

`internal-stroke` controls bevel contours separately. A layer-level value
overrides the stack value. `auto` matches each layer's exterior stroke, while an
explicit stroke gives bevel contours their own style. The stack default is
`none`.

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
and `brightness` is the final shading value.

`semi.debug.topology(body, ..layer-stack-arguments)` distinguishes exterior
outlines, material boundaries, internal edges, and occluded edges. It follows
the stack's `crease-angle`.

`semi.debug.gds(data)` lists the units, cells, and layers in a GDS file.

### Canvas

`length`, `baseline`, `background`, and `padding` pass through to `cetz.canvas`.
`stroke` styles Mesa's layer outlines.
`canvas-debug` shows CeTZ's bounding-box debugger.
