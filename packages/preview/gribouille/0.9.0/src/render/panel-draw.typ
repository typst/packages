// Panel renderer: the geom-dispatch table and `_draw-axis-and-layers`, which
// draws one panel: the coord's background (panel fill, gridlines, axes), the
// geom marks, the coord's foreground, the axis titles, and any panel-local
// legend.

#import "../deps.typ": cetz
#import "../utils/errors.typ": fail, fail-enum
#import "../scale/train.typ": mapping-display-name
#import "../theme/defaults.typ": resolve-colour
#import "../theme/theme.typ": _line-stroke, resolve-theme-palette
#import "../utils/palette.typ": spec-attr
#import "legend.typ" as legend-mod
#import "common.typ": (
  _per-side, _resolve-data, _resolve-mapping, _text-sides, _tick-cm-sides,
)
#import "colour.typ": _make-resolve-colour
#import "domain.typ": _flip-mapping
#import "prestat.typ": _rebase-level-spine
#import "axis-format.typ": _axis-title
#import "guides.typ": _axis-text-angle, _read-axis-guide
#import "extents.typ": (
  _AX-TITLE-LABEL-GAP, _text-margin-cm, _title-angle, _title-body,
  _title-extent-cm, _x-title-place, _y-title-place,
)

#import "../geom/registry.typ": GEOMS

#let _draw-axis-and-layers(
  prepared,
  trained,
  theme,
  spec,
  origin,
  inner-size,
  guides: (),
  legend-args: none,
  show-x-labels: true,
  show-y-labels: true,
  show-x-title: true,
  show-y-title: true,
  show-x-sec: true,
  show-y-sec: true,
  // Facet builders draw one secondary title for the whole grid, the way they
  // already do for the primary pair, so their panels keep the secondary ticks
  // and labels but drop the title.
  show-x-sec-title: true,
  show-y-sec-title: true,
  flipped: false,
  axis-breaks: none,
  x-extents: none,
  y-extents: none,
  x-title-extents: none,
  y-title-extents: none,
  x-sec-title-extents: none,
  y-sec-title-extents: none,
  x-sec-extents: none,
  y-sec-extents: none,
  // Band between the panel edge and its axis title, gap included, as
  // `_chrome-margins` reserved it. Carried rather than recomputed so the title
  // cannot land outside its own margin. The facet builders draw one title for
  // the whole grid and pass `show-x-title: false`, so these go unread there.
  x-edge-band: 0.0,
  y-edge-band: 0.0,
  canvas-w: 0,
  canvas-h: 0,
) = {
  import cetz.draw: *
  let (ox, oy) = origin
  let (iw, ih) = inner-size
  let px-lo = ox
  let px-hi = ox + iw
  let py-lo = oy
  let py-hi = oy + ih
  // `px-range`/`py-range` carry the inset *data area* (panel bounds shrunk by
  // any canvas-cm padding from `view-pad-cm`), so geoms and ticks land on the
  // correct data positions. Bare `px-lo`/`py-lo`/`px-hi`/`py-hi` keep the
  // outer panel bounds and are used for axis lines, panel fill, and gridline
  // endpoints that span the full panel.
  let _read-pad(t) = if t == none { (0, 0) } else {
    t.at("view-pad-cm", default: (0, 0))
  }
  let (x-pad-lo, x-pad-hi) = _read-pad(trained.at("x", default: none))
  let (y-pad-lo, y-pad-hi) = _read-pad(trained.at("y", default: none))
  let px-range = (px-lo + x-pad-lo, px-hi - x-pad-hi)
  let py-range = (py-lo + y-pad-lo, py-hi - y-pad-hi)

  let _ink = resolve-colour(theme, "ink")
  let _ax-text = _text-sides(theme, "axis-text")
  let _ax-title = _text-sides(theme, "axis-title")

  let _resolve-mapping-flipped(layer) = {
    let m = _resolve-mapping(layer, spec.mapping)
    if flipped { _flip-mapping(m) } else { m }
  }

  // Canonical per-draw context handed to every geom's `draw(layer, ctx)`
  // (GLOSSARY.md "ctx"): `trained`, `px-range`/`py-range` (panel extents in
  // canvas cm), `palette`, the `resolve-mapping`/`resolve-data`/
  // `resolve-colour` closures, `theme`, `flipped`, `canvas-w`/`canvas-h`, and
  // the resolved `coord` that projects points. The geom-dispatch copy
  // (`inner-ctx`, below) additionally carries `radial` (`none` on cartesian
  // panels); read optional keys with `ctx.at(key, default: ...)`.
  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: resolve-theme-palette(theme),
    resolve-mapping: layer => _resolve-mapping-flipped(layer),
    resolve-data: layer => _rebase-level-spine(
      _resolve-data(layer, spec.data),
      layer,
      trained,
      flipped: flipped,
    ),
    resolve-colour: _make-resolve-colour(_ink),
    theme: theme,
    flipped: flipped,
    canvas-w: canvas-w,
    canvas-h: canvas-h,
    coord: spec.coord,
  )

  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)

  let coord = spec.coord
  // How a scale's own `labels` and its typst marking reach the tick labels of
  // every axis the panel draws, angular and radial included.
  let _axis-display(trained) = (
    typst-mark: if trained != none {
      trained.at("typst-mark", default: false)
    } else { false },
    labels: spec-attr(trained, "labels", fallback: auto),
  )
  let _x-disp = _axis-display(x-trained)
  let _y-disp = _axis-display(y-trained)

  let _stroke-side = (p, s, _) => _line-stroke(
    theme,
    p + "-" + s,
    fallback-colour: _ink,
  )

  // The panel record (GLOSSARY.md "panel") the coord's `prepare`,
  // `draw-background`, and `draw-foreground` read: the panel state the
  // furniture around the geoms is drawn from.
  let panel = (
    theme: theme,
    spec: spec,
    coord: coord,
    trained: trained,
    x-trained: x-trained,
    y-trained: y-trained,
    px-lo: px-lo,
    px-hi: px-hi,
    py-lo: py-lo,
    py-hi: py-hi,
    px-range: px-range,
    py-range: py-range,
    canvas-w: canvas-w,
    canvas-h: canvas-h,
    ink: _ink,
    x-guide: _read-axis-guide(spec, "x", default-angle: _axis-text-angle(
      theme,
      "x",
    )),
    y-guide: _read-axis-guide(spec, "y", default-angle: _axis-text-angle(
      theme,
      "y",
    )),
    x-disp: _x-disp,
    y-disp: _y-disp,
    ax-text: _ax-text,
    ax-title: _ax-title,
    ax-line: _per-side(_stroke-side, "axis-line"),
    ax-ticks: _per-side(_stroke-side, "axis-ticks"),
    tick-len: _tick-cm-sides(theme),
    axis-breaks: axis-breaks,
    x-extents: x-extents,
    y-extents: y-extents,
    x-sec-extents: x-sec-extents,
    y-sec-extents: y-sec-extents,
    x-sec-title-extents: x-sec-title-extents,
    y-sec-title-extents: y-sec-title-extents,
    show-x-labels: show-x-labels,
    show-y-labels: show-y-labels,
    show-x-sec: show-x-sec,
    show-y-sec: show-y-sec,
    show-x-sec-title: show-x-sec-title,
    show-y-sec-title: show-y-sec-title,
  )
  let prep = (coord.prepare)(panel)
  let outer-radial = (coord.frame)(
    x-trained,
    y-trained,
    px-range,
    py-range,
    label-bounds: prep.label-bounds,
    tick-cm: prep.tick-cm,
  )
  panel += prep + (outer-radial: outer-radial)

  (coord.draw-background)(panel)

  // Render geoms into a sibling cetz canvas whose origin is (0, 0) and whose
  // bounds match the panel rectangle, then clip via Typst's `box(clip: true)`
  // before placing it back at the panel's south-west corner. cetz 0.5.0 has
  // no native clip primitive, so this nested-canvas hop is the only way to
  // bound geom marks to the panel.
  // Floored at zero: `box(clip: true, width: panel-w * 1cm, ...)` below is the
  // one place a negative extent would reach Typst.
  let panel-w = calc.max(0.0, px-hi - px-lo)
  let panel-h = calc.max(0.0, py-hi - py-lo)
  let inner-ctx = ctx
  inner-ctx.px-range = (x-pad-lo, panel-w - x-pad-hi)
  inner-ctx.py-range = (y-pad-lo, panel-h - y-pad-hi)
  let inner-radial = (coord.frame)(
    x-trained,
    y-trained,
    inner-ctx.px-range,
    inner-ctx.py-range,
    label-bounds: prep.label-bounds,
    tick-cm: prep.tick-cm,
  )
  inner-ctx.radial = inner-radial
  for layer in prepared {
    if layer.name not in GEOMS {
      fail-enum("plot", "geom", layer.name, GEOMS.keys())
    }
    if not (coord.supports)(layer.name) {
      fail(
        "coord-" + coord.name,
        "does not support geom-" + layer.name,
        hint: coord.unsupported-hint,
      )
    }
  }
  // Every geom is drawn `floating`, so it never contributes to the canvas
  // bounds; only the `hide(rect ...)` does. Each subset canvas is therefore
  // exactly panel-sized with its origin at the south-west corner, so the
  // clipped and unclipped passes overlay in perfect register.
  let _draw-subset = subset => cetz.canvas({
    import cetz.draw: floating, hide, rect
    hide(rect((0, 0), (panel-w, panel-h)), bounds: true)
    for layer in subset {
      floating({ (GEOMS.at(layer.name).draw)(layer, inner-ctx) })
    }
  })
  // `annotate(clip: false)` opts a layer out of the panel clip; render it in a
  // sibling pass with no clip box so it can overflow the panel deliberately.
  // The sibling pass paints after the clipped one, so unclipped marks always
  // sit above clipped layers (documented on `annotate`'s `clip`).
  let clipped = prepared.filter(l => l.at("clip", default: true))
  let unclipped = prepared.filter(l => not l.at("clip", default: true))
  let clipped-geoms = _draw-subset(clipped)
  content(
    (px-lo, py-lo),
    if coord.clip {
      box(
        clip: true,
        width: panel-w * 1cm,
        height: panel-h * 1cm,
        clipped-geoms,
      )
    } else { clipped-geoms },
    anchor: "south-west",
  )
  if unclipped.len() > 0 {
    content((px-lo, py-lo), _draw-subset(unclipped), anchor: "south-west")
  }

  // Coord furniture that sits above the geoms, such as the radial-axis tick
  // labels, renders after them so filled marks cannot mask it.
  (coord.draw-foreground)(panel)

  // When flipped, the bottom axis shows the user's original y mapping and
  // the left axis shows the user's original x mapping; trained.x and
  // trained.y already carry the swapped scale specs (and labels labels), so
  // only the mapping-name fallback needs an explicit swap here.
  let _mapping-x-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("y", default: none))
  } else { mapping-display-name(spec.mapping.at("x", default: none)) }
  let _mapping-y-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("x", default: none))
  } else { mapping-display-name(spec.mapping.at("y", default: none)) }
  let x-title = _axis-title(x-trained, _mapping-x-name)
  let y-title = _axis-title(y-trained, _mapping-y-name)
  let x-title-cm = _title-extent-cm(_ax-title.xb, x-title-extents, "x")
  let y-title-cm = _title-extent-cm(_ax-title.yl, y-title-extents, "y")
  let x-title-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  let y-title-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  // A suppressed axis (`guides(x: none)`) draws no ticks or labels and a radial
  // panel draws neither band outside the panel, so in both cases the title
  // slides up to the panel edge. Both gates already ran in `_chrome-margins`,
  // which is why the band arrives rather than being derived a second time.
  let x-edge-offset = x-edge-band + x-title-gap
  let y-edge-offset = y-edge-band + y-title-gap
  if show-x-title and x-title != none and _ax-title.xb.size > 0pt {
    let (cx, x-anchor) = _x-title-place(_ax-title.xb.align, px-lo, px-hi)
    content(
      (cx, oy - (x-edge-offset + x-title-cm)),
      _title-body(
        x-title,
        _ax-title.xb,
        x-title-extents,
      ),
      anchor: x-anchor,
      angle: _title-angle(_ax-title.xb, 0),
    )
  }
  if show-y-title and y-title != none and _ax-title.yl.size > 0pt {
    let (cy, y-anchor) = _y-title-place(_ax-title.yl.align, py-lo, py-hi)
    content(
      (px-lo - (y-edge-offset + y-title-cm / 2), cy),
      _title-body(
        y-title,
        _ax-title.yl,
        y-title-extents,
      ),
      angle: _title-angle(_ax-title.yl, 90),
      anchor: y-anchor,
    )
  }

  if guides.len() > 0 and legend-args != none {
    legend-mod.draw(
      guides,
      ctx,
      panel-rect: legend-args.panel-rect,
      margin: legend-args.margin,
      legend-gap: legend-args.legend-gap,
      sec-y-extent: legend-args.sec-y-extent,
      sec-x-extent: legend-args.sec-x-extent,
      right-strip: legend-args.right-strip,
      theme: theme,
    )
  }
}
