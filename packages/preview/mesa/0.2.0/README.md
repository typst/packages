# Mesa

Draw 2D and 3D semiconductor devices and fabrication processes with
[CeTZ](https://github.com/cetz-package/cetz), including patterned geometry
loaded from GDS.

```typ
#import "@preview/mesa:0.2.0" as semi

#set page(width: auto, height: auto, margin: 8mm)

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

#semi.layer-stack(
  sample,
  camera: (azimuth: 35deg, elevation: 35deg),
  shading: "fancy",
)
```

![A material stack rendered with Mesa](assets/layer-stack.png)

GDS layouts can also be used to produce process-flow steps.

![A transistor fabrication process rendered with Mesa](assets/process-flow.png)

See the [usage manual](manual.md) for the complete API.

> DISCLAIMER: >80% of Typst code and 100% of Rust code was LLM-written, guided by me at a high level. I'm not fluent in Rust and I couldn't have justified writing this package otherwise. Since this is only a visualization tool, I felt that vibe coding it could be justified. Nonetheless, I have been using it for my own projects and have been happy with the results.

In case of any bugs or missing features, please [open an issue](https://github.com/digiefel/mesa/issues) on GitHub.

## Changelog

### 0.2.0

Improved support for larger and more complex GDS layouts.
Paths are now supported, lateral x and y layout dimensions can be
rescaled on import to improve visual presentation clarity, and the renderer
has been improved and optimized to render hundreds of faces within a second.

- GDS `PATH` elements are imported with their widths and end styles. 
  Dense paths may be simplified with `path-tolerance` to optimize document 
  compile times.
- Imported layouts retain their declared physical unit and can be converted to
  nanometres, micrometres, millimetres, or a custom unit. Independent `x` and
  `y` scaling can make large devices legible without changing vertical process
  dimensions, while configurable padding provides room around the layout.
- Fancy shading now projects the actual shape of cast shadows onto receiving
  surfaces. Narrow gates and patterned features can cast "proper" shadows.
  Flat shading does not project shadows, as before.
- Rectangular and patterned layers now share the same rendering path. Lighting,
  bevels, fades, cuts, outlines, and debug views therefore behave consistently
  when both kinds of geometry appear in one sample.
- Complex and finely segmented layouts render more efficiently. `crease-angle`
  was added to visually smooth curves, and rounded stroke caps prevent 
  small gaps where outline segments meet.
- A stack-level `stroke` sets a common exterior-outline style while preserving
  per-layer overrides.
- GDS coordinates now use the file's declared unit by default. A preferred unit
  can be specified and layout coordinates will be converted to it.
- Layouts can be padded to extend the substrate around the mask automatically.

### 0.1.0

Initial release
