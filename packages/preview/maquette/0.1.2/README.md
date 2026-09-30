# Maquette

[![Typst Universe](https://img.shields.io/badge/Typst%20Universe-maquette-239dad)](https://typst.app/universe/package/maquette)
[![Live demo](https://img.shields.io/badge/demo-live-4f46e5)](https://bernsteining.github.io/maquette/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Maquette is a [Typst](https://typst.app) plugin that renders 3D models directly inside your documents — no screenshots, no external tools, no manual re-exports when you tweak the camera angle.

Maquette takes STL, OBJ, and PLY files and turns them into SVG or PNG images at compile time, right inside the Typst pipeline. Point a camera, set up lighting, pick a shading model, and the result lands in your PDF. Change a parameter, recompile, done. This makes it practical to embed technical 3D illustrations in engineering reports, research papers, and documentation without maintaining a separate asset pipeline.

Everything runs as a single WASM plugin (~485 KB), with focus on speed.

**[Try it live in your browser →](https://bernsteining.github.io/maquette/)** — drag to orbit, tweak every setting, and copy the generated Typst code. It runs the exact same WASM as the plugin, fully client-side. Because your browser JIT-compiles the WASM (Typst runs it in an interpreter), the demo is dramatically faster to iterate on — the quickest way to dial in a camera angle and lighting before pasting the code into your document, with no recompile between tweaks.

Check the [documentation](https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/documentation.pdf) to see examples of all the features.

## Example

A back-lit Stanford bunny: a red point light placed *inside* the model glows through the thin ears (subsurface scattering), with the camera framed from behind. Lighting, camera and material all live in the source.

<table>
<tr>
<td>

```typst
#import "@preview/maquette:0.1.2": render-obj
#let bunny = read("examples/data/bunny.obj", encoding: none)

#render-obj(bunny,
  up: (0, 1, 0),
  azimuth: 180,
  distance: 0.25,
  background: none,
  lights: (
    (type: "positional",
     vector: (-0.1, 0.14, -0.04),
     color: "#ff0000", intensity: 3.0),
  ),
  sss: (intensity: 4, power: 3.5, distortion: 0.2),
  antialias: 4)
```

</td>
<td>
<img src="https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/sss_bunny.png" width="100%" alt="Back-lit Stanford bunny with subsurface scattering" />
</td>
</tr>
</table>

## Gallery

<table>
<tr>
<td align="center" width="50%">
<img src="https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/gallery_multiview.svg" width="100%" alt="Multi-view grid" /><br/>
<sub><b>Multi-view grid</b> — front / right / top / isometric on one sheet</sub>
</td>
<td align="center" width="50%">
<img src="https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/gallery_groups.png" width="100%" alt="Per-group appearance" /><br/>
<sub><b>Per-group appearance</b> — per-part colour, stroke &amp; opacity from OBJ groups</sub>
</td>
</tr>
<tr>
<td align="center">
<img src="https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/gallery_scalar.png" width="100%" alt="Scalar color map" /><br/>
<sub><b>Scalar color map</b> — a math expression <code>f(x,y,z)</code> over a custom palette</sub>
</td>
<td align="center">
<img src="https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/gallery_clip.png" width="100%" alt="Clipping plane" /><br/>
<sub><b>Clipping plane</b> — a mathematical cut opens the model to its interior</sub>
</td>
</tr>
</table>

Once again, the [documentation](https://raw.githubusercontent.com/bernsteining/maquette/v0.1.2/examples/documentation.pdf) has many examples covering all the features offered by `maquette`.

## Functions

### `render-stl` / `render-obj` / `render-ply`

```typst
#render-stl(read("model.stl", encoding: none), ..config, width: auto, height: auto, format: "png")
#render-obj(obj-data, ..config, width: auto, height: auto, format: "png")
#render-ply(read("model.ply", encoding: none), ..config, width: auto, height: auto, format: "png")
```

Renders a 3D model. Data must be read with `encoding: none` (required for binary STL/PLY, optional for OBJ). Configuration parameters are passed as named arguments (e.g. `color: "#c0ffee"`), or bundled into a single dictionary passed positionally (`render-stl(data, (color: "#c0ffee"))`) — both are equivalent. Any parameter set to `none` falls back to its default. `width`/`height`/`format` control display sizing and output format; set `format: "svg"` for vector output.

> **Read PLY & STL models with `encoding: none`.** This hands maquette the raw file bytes. Binary STL/PLY — and any file with non-UTF-8 bytes — otherwise fail Typst's default UTF-8 `read()` with a *"file is not valid UTF-8"* error. `encoding: none` avoids that and works for every format (OBJ included), so it's the pattern to use everywhere.


### `get-stl-info` / `get-obj-info` / `get-ply-info`

```typst
#let info = get-stl-info(stl-data)
#let info = get-obj-info(obj-data)
#let info = get-ply-info(ply-data)
```

Returns JSON with model metadata (triangle count, vertex count, bounding box, groups).

## Output Formats

- **PNG** (default): Z-buffer rasterized. Best for high-poly models and smooth shading. Set `width`/`height` for resolution and `antialias` for supersampling.
- **SVG** (`format: "svg"`): Vector output via painter's algorithm. Best for low-to-medium poly models. Supports debug overlays and silhouette outlines.
