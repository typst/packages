// Mirrors upstream src/xyzrender/__init__.py.
//
// Users get the package via:
//   #import "@preview/xyzrender:0.1.0": xyzrender
//
// Upstream `__init__.py` exports:
//   from api:    Molecule, load, measure, orient, render, render_gif
//   from types:  GIFResult, OverlayConfig, RenderConfig, StyleRegion,
//                SVGResult
//   from config: build_config
//   from annotations: load_cmap
//   plus configure_logging, __version__
//
// In the v1 Typst surface only the equivalent of upstream `render` is
// exposed (as `xyzrender`). The rest correspond to features explicitly
// out of scope (PLAN.md:23-29) or are Python-only concepts (dataclasses,
// GIF result wrappers, etc.). Document-wide kwarg defaults — which have
// no upstream parallel, Python has no show rules — are a call-site
// concern handled by rebinding with `.with()`, not a library export.

#import "api.typ": xyzrender
