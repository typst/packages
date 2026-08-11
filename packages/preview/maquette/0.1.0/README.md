# Maquette

Maquette is a [Typst](https://typst.app) plugin that renders 3D models directly inside your documents — no screenshots, no external tools, no manual re-exports when you tweak the camera angle.

Maquette takes STL, OBJ, and PLY files and turns them into SVG or PNG images at compile time, right inside the Typst pipeline. Point a camera, set up lighting, pick a shading model, and the result lands in your PDF. Change a parameter, recompile, done. This makes it practical to embed technical 3D illustrations in engineering reports, research papers, and documentation without maintaining a separate asset pipeline.

Everything runs as a single WASM plugin (~460 KB), with focus on speed.

Check the [documentation](https://github.com/bernsteining/maquette/blob/v0.1.0/examples/documentation.pdf) to see examples of all the features.

# Usage

```typst
#import "@preview/maquette:0.1.0": render-obj
#let cube = read("examples/data/bunny.obj")
#render-obj(cube)
```

## Rendering Techniques

| Category | Technique | Description |
|---|---|---|
| **Shading** | Blinn-Phong | Physically-motivated diffuse + specular highlights (default) |
| | Flat | Unlit, base color only — no lighting calculations |
| | Cel / Toon | Discrete color bands with configurable step count |
| | Gooch | Warm-to-cool non-photorealistic shading for technical illustration |
| | Normal | View-space normal visualization |
| | Smooth (Gouraud) | Per-vertex normal interpolation for curved surfaces |
| **Lighting** | Directional lights | Infinite light sources (sun-like) |
| | Point lights | Positional light sources with distance falloff |
| | Multi-light | Combine multiple lights with individual color and intensity |
| | Hemisphere ambient | Sky/ground gradient ambient lighting |
| | Fresnel rim | Edge glow effect based on view angle |
| | Specular highlights | Blinn-Phong half-vector reflections |
| | Subsurface scattering | Fake SSS for translucent materials (skin, wax, marble) |
| **Rendering** | Z-buffer rasterization | Pixel-accurate PNG output with depth testing |
| | Painter's algorithm | Depth-sorted SVG polygon output |
| | Wireframe | Full mesh topology edges, no fill |
| | Solid + Wireframe | Shaded surface with mesh overlay |
| | X-Ray | Transparent front faces, opaque back faces |
| **Post-processing** | SSAO | Screen-space ambient occlusion with bilateral blur |
| | FXAA | Fast approximate anti-aliasing |
| | SSAA | Supersampled anti-aliasing (2×, 4×) |
| | Bloom | Bright area bleed for HDR glow |
| | Glow | Colored edge glow effect |
| | Sharpen | Unsharp mask sharpening filter |
| | Tone mapping | Reinhard or ACES operators for HDR-to-LDR conversion |
| | Gamma correction | Linear-to-sRGB conversion |
| **Visualization** | Color maps | Height, overhang, curvature, or custom scalar function |
| | Silhouette outlines | Contour edge detection and rendering |
| | Ground shadows | Projected shadow onto ground plane |
| | Clipping planes | Mathematical plane cuts with interior visibility |
| | Exploded views | Auto-separate components outward from center |
| | Annotations | Leader lines with labels for OBJ group names |
| **Point Clouds** | k-NN triangulation | Automatic mesh reconstruction from unstructured point clouds |
| **Projection** | Perspective | Standard perspective with configurable FOV |
| | Orthographic | Parallel projection for technical drawings |
| | Isometric | Fixed isometric view |
| | Cabinet / Cavalier | Oblique parallel projections |
| | Fisheye | Wide-angle barrel distortion |
| | Stereographic | Conformal wide-angle projection |
| | Curvilinear | Panini-style rectilinear correction |
| | Cylindrical | Equidistant cylindrical mapping |
| | Pannini | Pannini projection for architectural scenes |
| | Tiny Planet | 360° inverse stereographic (little planet effect) |
| **Layout** | Multi-view grid | Named views (front, right, top, isometric, ...) in a grid |
| | Turntable | Evenly-spaced rotation views at fixed elevation |
| **Formats** | STL | Binary STL with optional per-face RGB565 colors |
| | OBJ | Wavefront OBJ with groups, materials |
| | PLY | Binary/ASCII PLY with per-vertex colors and point cloud support |

## Documentation

See [examples/documentation.pdf](https://github.com/bernsteining/maquette/blob/v0.1.0/examples/documentation.pdf) for a full walkthrough with examples, or compile it:

```sh
make demo
```

## Functions

### `render-stl` / `render-obj` / `render-ply`

```typst
#render-stl(stl-data, config, width: auto, height: auto, format: "png")
#render-obj(obj-data, config, width: auto, height: auto, format: "png")
#render-ply(ply-data, config, width: auto, height: auto, format: "png")
```

Renders a 3D model. Data must be read with `encoding: none` (required for binary STL/PLY, optional for OBJ). Config is a JSON string via `json.encode((...))`. Set `format: "svg"` for vector output.

### `get-stl-info` / `get-obj-info` / `get-ply-info`

```typst
#let info = get-stl-info(stl-data, json.encode(()))
#let info = get-obj-info(obj-data, json.encode(()))
#let info = get-ply-info(ply-data, json.encode(()))
```

Returns JSON with model metadata (triangle count, vertex count, bounding box, groups).

## Output Formats

- **PNG** (default): Z-buffer rasterized. Best for high-poly models and smooth shading. Set `width`/`height` for resolution and `antialias` for supersampling.
- **SVG** (`format: "svg"`): Vector output via painter's algorithm. Best for low-to-medium poly models. Supports debug overlays and silhouette outlines.

## Config Reference

### Camera & Viewport

| Key | Default | Description |
|---|---|---|
| `camera` | `null` | Camera position `(x, y, z)` in world space. Overrides `azimuth`/`elevation` |
| `azimuth` | `0` | Horizontal angle in degrees around the model |
| `elevation` | `0` | Vertical angle in degrees above the horizontal plane |
| `distance` | `null` | Camera distance from center (`null` = auto from bounding box) |
| `center` | `(0, 0, 0)` | Look-at target (overridden by `auto_center`) |
| `up` | `(0, 0, 1)` | Up direction. Z-up (CAD/STL) by default; use `(0, 1, 0)` for Y-up (Blender, game engines) |
| `fov` | `45` | Vertical field of view in degrees (perspective only) |
| `projection` | `"perspective"` | `"perspective"`, `"orthographic"`, `"isometric"`, `"cabinet"`, `"cavalier"`, `"fisheye"`, `"stereographic"`, `"curvilinear"`, `"cylindrical"`, `"pannini"`, `"tiny-planet"` |
| `auto_center` | `true` | Auto-center camera on model bounding box |
| `auto_fit` | `true` | Scale model to fill viewport |
| `width` | `500` | Output width in pixels |
| `height` | `500` | Output height in pixels |
| `background` | `"#f0f0f0"` | Background color (hex). Empty string = transparent |

### Appearance

| Key | Default | Description |
|---|---|---|
| `color` | `"#4488cc"` | Model fill color (hex) |
| `stroke` | `"none"` | Triangle edge stroke: color string or `{ color, width }` |
| `mode` | `"solid"` | `"solid"`, `"wireframe"`, `"solid+wireframe"`, `"x-ray"` |
| `smooth` | `true` | Gouraud smooth shading (per-vertex normals) |
| `cull_backface` | `true` | Back-face culling |
| `opacity` | `1.0` | Global model opacity (0--1) |
| `xray_opacity` | `0.1` | Front-face opacity in x-ray mode (0--1) |
| `wireframe` | `""` | Wireframe overlay: color string or `{ color, width }` |
| `materials` | `{}` | OBJ material map: `{ "name": "#hex" }` for `usemtl` |
| `highlight` | `{}` | OBJ group overrides: `{ "name": "#hex" }` or `{ "name": { color, opacity, specular, ... } }` |

### Shading & Lighting

| Key | Default | Description |
|---|---|---|
| `shading` | `""` | Shading model: `""` (Blinn-Phong), `"flat"`, `"cel"`, `"gooch"`, `"normal"` |
| `light_dir` | `(1, 2, 3)` | Default directional light vector |
| `ambient` | `0.15` | Ambient light intensity (0--1), or `{ intensity, sky, ground }` for hemisphere |
| `specular` | `0.2` | Specular highlight intensity (0--1) |
| `shininess` | `32` | Specular exponent (higher = tighter highlights) |
| `fresnel` | `0.3` | Fresnel rim: intensity (0--1), or `{ intensity, power }` |
| `lights` | `[]` | Multi-light array: `{ type, vector, color, intensity }` per light |
| `gooch_warm` | `"#ffcc44"` | Gooch warm tone color |
| `gooch_cool` | `"#4466cc"` | Gooch cool tone color |
| `cel_bands` | `4` | Number of discrete bands for cel shading |
| `sss` | `false` | Subsurface scattering: `true` or `{ intensity, power, distortion }` |
| `gamma_correction` | `true` | Linear-to-sRGB gamma correction |
| `tone_mapping` | `""` | Tone mapping: `""` (off), `"reinhard"`, `"aces"`, or `{ method, exposure }` |

### Color Mapping

| Key | Default | Description |
|---|---|---|
| `color_map` | `""` | `"height"`, `"overhang"`, `"curvature"`, `"scalar"`, or `""` (off) |
| `color_map_palette` | `[]` | Custom hex color gradient |
| `scalar_function` | `""` | Math expression for scalar mode, e.g. `"sqrt(x*x+y*y)"` |
| `vertex_smoothing` | `4` | Smooth color values across vertices (0--4) |
| `overhang_angle` | `45` | Overhang threshold in degrees |

### Outlines

| Key | Default | Description |
|---|---|---|
| `outline` | `false` | Silhouette edge outlines: `true` or `{ color, width }` |

### Effects

| Key | Default | Description |
|---|---|---|
| `ground_shadow` | `false` | Ground shadow: `true` or `{ opacity, color }` |
| `clip_plane` | `null` | Clipping plane `(a, b, c, d)`: keeps `ax+by+cz+d >= 0` |
| `explode` | `0` | Exploded view factor (OBJ groups or auto-detected components) |
| `antialias` | `1` | Supersampling for PNG (`2` = 2×2 SSAA, `4` = 4×4) |
| `fxaa` | `true` | Fast approximate anti-aliasing (PNG only) |
| `ssao` | `false` | Screen-space AO: `true` or `{ samples, radius, bias, strength }` |
| `bloom` | `false` | Bloom: `true` or `{ threshold, intensity, radius }` |
| `glow` | `false` | Glow: `true` or `{ color, intensity, radius }` |
| `sharpen` | `false` | Sharpen: `true` or `{ strength }` |
| `point_size` | `0` | Point cloud neighbor search radius (`0` = auto from point density) |

### Annotations

| Key | Default | Description |
|---|---|---|
| `annotations` | `false` | Annotate OBJ groups: `true` or `{ groups, color, font_size, offset }` |

### Multi-View

| Key | Default | Description |
|---|---|---|
| `views` | `null` | Named view grid: `("front", "right", "top", "isometric")` |
| `turntable` | `0` | Turntable views: count, or `{ iterations, elevation }` |
| `grid_labels` | `true` | Show labels on multi-view / turntable grids |

### Diagnostics

| Key | Default | Description |
|---|---|---|
| `debug` | `false` | Overlay model metadata and light positions |
| `debug_color` | `"#cc2222"` | Debug text color |

## Full Config

```json
{ // ── Camera & Viewport ─────────────────────────────────────────────
"camera": [3, 3, 3],
// Camera position in world space (Cartesian)
"azimuth": null,
// Spherical camera: horizontal angle in degrees
"elevation": null,
// Spherical camera: vertical angle in degrees
"distance": null,
// Spherical camera: distance from center (auto)
"center": [0, 0, 0],
// Look-at target (overridden by auto_center)
"up": [0, 0, 1],
// Up direction vector
"fov": 45,
// Vertical FOV in degrees (perspective only)
"projection": "perspective",
// "perspective", "orthographic", "isometric", "cabinet", "cavalier",
// "fisheye", "stereographic", "curvilinear", "cylindrical", "pannini",
// "tiny-planet"
"auto_center": true,
// Auto-center on model bounding box
"auto_fit": true,
// Scale model to fill viewport
"width": 500,
// Output width in pixels
"height": 500,
// Output height in pixels
"background": "#f0f0f0",
// Background color (hex), "" = transparent
// ── Appearance ────────────────────────────────────────────────────
"color": "#4488cc",
// Model fill color (hex)
"stroke": "none",
// Triangle edge stroke: color string or { color, width }
"light_dir": [1, 2, 3],
// Directional light vector
"ambient": 0.15,
// Ambient light intensity (0-1), or { intensity, sky, ground }
"mode": "solid",
// "solid", "wireframe", "solid+wireframe", "x-ray"
"opacity": 1.0,
// Global model opacity (0-1)
"xray_opacity": 0.1,
// Front-face opacity for x-ray mode (0-1)
"cull_backface": true,
// Back-face culling (auto-disabled for x-ray)
"wireframe": "",
// Wireframe overlay: color string or { color, width }
"smooth": true,
// Gouraud smooth shading (best with PNG)
"specular": 0.2,
// Specular highlight intensity (0-1)
"shininess": 32,
// Specular exponent (higher = tighter)
"gamma_correction": true,
// Compute lighting in linear sRGB space
"fresnel": 0.3,
// Fresnel rim lighting: intensity (0-1), or { intensity, power }
"lights": [],
// Array of light definitions (see Multi-Light)
"tone_mapping": "",
// "reinhard", "aces", or { method, exposure }
"shading": "",
// "blinn-phong" (default), "gooch", "cel", "flat", or "normal"
"gooch_warm": "#ffcc44",
// Gooch warm tone color
"gooch_cool": "#4466cc",
// Gooch cool tone color
"cel_bands": 4,
// Number of cel-shading bands
"sss": false,
// Subsurface scattering: true or { intensity, power, distortion }
"materials": {},
// OBJ material map: { "name": "#hex" }
"highlight": {},
// OBJ group highlight: "#hex" or { color, specular, ... }
// ── Color Mapping ─────────────────────────────────────────────────
"color_map": "",
// "height", "overhang", "curvature", "scalar", or "" (off)
"color_map_palette": [],
// Custom hex color gradient
"scalar_function": "",
// Math expression for scalar mode: "sqrt(x*x+y*y+z*z)"
"vertex_smoothing": 4,
// Smooth color values across vertices (0-4)
"overhang_angle": 45,
// Overhang threshold in degrees
// ── Outlines ──────────────────────────────────────────────────────
"outline": false,
// Silhouette edge outlines: true or { color, width }
// ── Effects ───────────────────────────────────────────────────────
"ground_shadow": false,
// Ground shadow: true or { opacity, color }
"clip_plane": null,
// Clipping plane (a, b, c, d)
"explode": 0,
// Exploded view factor
"point_size": 0,
// Point cloud splat radius (0 = auto)
"antialias": 1,
// Supersampling for PNG (2 = 2x2 SSAA, 4 = 4x4)
"fxaa": true,
// Fast approximate anti-aliasing (PNG only)
"ssao": false,
// Screen-space AO: true or { samples, radius, bias, strength }
"bloom": false,
// Bloom: true or { threshold, intensity, radius }
"glow": false,
// Glow: true or { color, intensity, radius }
"sharpen": false,
// Sharpen: true or { strength }
// ── Annotations ─────────────────────────────────────────────────
"annotations": false,
// Annotate OBJ groups: true or { groups, color, font_size, offset }
// ── Multi-View ────────────────────────────────────────────────────
"views": null,
// Named views: ["front", "right", "top", ...]
"turntable": 0,
// Turntable views: count, or { iterations, elevation }
"grid_labels": true,
// Show labels on multi-view grids
// ── Diagnostics ───────────────────────────────────────────────────
"debug": false,
// Overlay model metadata
"debug_color": "#cc2222"
// Debug text color
}
```

## Building

```sh
make build    # cargo build → wasm-opt -O3 → deploy
make doc      # build + compile examples/documentation.pdf
```

Requires `cargo`, `wasm32-unknown-unknown` target, and `wasm-opt` (from [binaryen](https://github.com/WebAssembly/binaryen)).
