/// The installed scenery package version.
#let scenery-version = version(0, 1, 0)

// Pure scene-core math: vector/matrix helpers and the orthographic camera.
#import "src/linalg.typ": vadd, vsub, vscale, vdot, vcross, vlen, vnorm, mvec, lerp
#import "src/camera.typ": camera, camera-2d, project, project-scale
#import "src/coordinate.typ": anchor-ref

// Typed primitives, affine transforms and scene assembly (pure data, no cetz).
#import "src/scene.typ": sphere, seg, edge, arrow, face, mesh, label, affine, translate, scale, group, build-scene
#import "src/anchors.typ": resolve-scene, anchor-of, anchor-names

// Shape generators: convex hull faces and parametric solid meshes.
#import "src/shape.typ": hull-faces, uv-sphere, cylinder, cone, prism

// Theme data and per-primitive style resolution (pure data, no cetz).
#import "src/style.typ": default-theme, resolve-style, palette-color

// Depth-sort (pure) and the cetz painter's-algorithm backend.
#import "src/render.typ": sort-prims, scene-group, render-scene

// The WASM geometry accelerator (`engine.typ`) is intentionally NOT re-exported
// here: `engine.typ` calls `plugin(..)` at module-eval time, so importing it
// would eagerly load the blob and make the pure-Typst default path depend on it.
// The public accelerator API is the `engine: "wasm"` parameter on `scene-group`/
// `render-scene`, which `render.typ` wires with an import scoped to that branch.
// Internals (`engine-sort`/`engine-version`) are reachable via `/src/engine.typ`.

// Annotation furniture: axes triad, legend, colorbar (cetz draw commands).
#import "src/annotate.typ": axes-triad, legend, colorbar
