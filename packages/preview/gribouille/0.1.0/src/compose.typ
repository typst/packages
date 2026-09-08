#import "render.typ": render-plot-deferred
#import "legend.typ" as legend-mod
#import "theme/current.typ": _theme-state
#import "theme/defaults.typ": merge-theme
#import "theme/elements.typ": margin

#let _is-plot-spec(x) = (
  type(x) == dictionary
    and "layers" in x
    and "data" in x
    and "width" in x
    and "height" in x
    and "guides" in x
)

#let _index-by-aesthetic(guides) = {
  let out = (:)
  for g in guides {
    for a in g.at("aesthetics", default: ()) {
      out.insert(a, g)
    }
  }
  out
}

#let _all-mergeable(per-panel, aes-name) = {
  let first = none
  for idx in per-panel {
    let g = idx.at(aes-name, default: none)
    if g == none { return false }
    if first == none {
      first = g
    } else if not legend-mod.can-merge-cross-panel(first, g) {
      return false
    }
  }
  first != none
}

// Compose's heuristic sizing pass uses the default 9pt body. The visible
// legend is re-rendered via `standalone()` later with the actual theme.
#let _COMPOSE-SIZE-PT = 9

#let _coerce-placement(g, side) = legend-mod.recompute-extent(
  (
    ..g,
    placement: (
      ..g.placement,
      side: side,
      direction: if side == "top" or side == "bottom" {
        "horizontal"
      } else { "vertical" },
    ),
  ),
  _COMPOSE-SIZE-PT,
)

#let _legend-canvas-size(guides, side) = {
  let extents = legend-mod.estimate-extents(guides)
  if side == "right" or side == "left" {
    let height = 0.0
    for g in guides { height += g.at("height", default: 0.0) + 0.2 }
    (width: extents.at(side), height: height)
  } else {
    let width = 0.0
    for g in guides { width += g.at("width", default: 0.0) + 0.15 }
    (width: width, height: extents.at(side))
  }
}

/// Arrange multiple plots into a grid or stack with a shared, hoisted legend.
///
/// `compose` is the multi-plot orchestrator: it takes deferred plots, probes
/// each panel's would-be guides, decides which legends are identical across
/// every panel, lifts them into a single shared block on the requested side,
/// and re-renders the panels with the hoisted aesthetics suppressed so each
/// reclaims the margin its legend would have occupied. Inspired by
/// `patchwork::plot_layout(guides = "collect")`.
///
/// Every positional argument must be a deferred plot (`plot(..., defer: true)`);
/// passing rendered content panics, because compose needs the spec to re-render.
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ..panels-positional Two or more deferred plots produced by\@plot with
///   `defer: true`. Order is preserved by the layout (left-to-right, top-to-bottom
///   for grids; per `dir` for stacks).
///
/// \@param layout `"grid"` (default) lays panels into a Typst `grid` with `columns`
///   columns; `"stack"` lays them into a Typst `stack` flowing in `dir`.
///
/// \@param columns Number of columns in `"grid"` layout. Ignored for `"stack"`.
///
/// \@param direction Stack direction (`ttb`, `btt`, `ltr`, `rtl`) used by
///   `"stack"` layout. Ignored for `"grid"`.
///
/// \@param gutter Spacing between panels and between the panel block and the
///   shared legend.
///
/// \@param collect Which aesthetics to hoist into the shared legend.
///   - `auto` (default) hoists every aesthetic whose guide is identical across
///     all panels (kind, title, levels/domain, breaks, labels, aesthetic mix).
///     Aesthetics that disagree on any of those fields stay per-plot, so a
///     mismatched panel never silently borrows another panel's legend.
///   - `none` disables hoisting entirely; each plot keeps its own legends.
///   - An array of aesthetic names (e.g., `("colour", "fill")`) restricts
///     hoisting to the listed aesthetics. Listed aesthetics that aren't
///     mergeable across panels still stay per-plot; non-listed aesthetics
///     are never hoisted regardless of agreement.
///   The merge predicate ignores per-panel placement and grid shape (`nrow` /
///   `ncol`); compose forces a single shared side and grid layout for the
///   hoisted block. Custom guides (`guide-custom`) never hoist.
///
/// \@param guides-placement Side where the shared legend appears, relative to
///   the panel block. One of `"right"` (default), `"left"`, `"top"`, or
///   `"bottom"`. The hoisted guides' direction is set automatically:
///   `"vertical"` for left/right, `"horizontal"` for top/bottom.
///
/// \@returns Typst content block: the panel layout with the shared legend
///   stacked on `guides-placement`, or the bare panel layout when no aesthetic
///   ends up hoisted.
///
/// \@examples Auto-collect: identical `colour` legend hoisted to the right.
/// ```
/// //| alt: "Two side-by-side mpg scatter panels sharing a single colour legend by cylinder count hoisted to the right of the panel grid."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 3pt),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"))),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"))),
///   layout: "grid", columns: (auto, auto),
/// )
/// ```
///
/// \@examples Restrict hoisting: shared `colour` only, per-plot `size` ladders
/// stay in each panel.
/// ```
/// //| alt: "Two mpg scatter panels sharing a single colour-by-cylinder legend on the right while each panel keeps its own size legend bound to a different column."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"), size: "cty")),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"), size: "hwy")),
///   layout: "grid", columns: (auto, auto),
///   collect: ("colour",),
/// )
/// ```
///
/// \@examples Place the shared legend below the panels.
/// ```
/// //| alt: "Two side-by-side mpg scatter panels sharing a single colour-by-cylinder legend placed horizontally below the panel grid."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 3pt),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"))),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"))),
///   layout: "grid", columns: (auto, auto),
///   guides-placement: "bottom",
/// )
/// ```
///
/// \@see\@plot,\@aes,\@guides
#let compose(
  ..panels-positional,
  layout: "grid",
  columns: 2,
  direction: ttb,
  gutter: 0.5cm,
  collect: auto,
  guides-placement: "right",
) = {
  let panels = panels-positional.pos()
  if panels.len() == 0 {
    panic("compose: at least one deferred plot is required")
  }
  for p in panels {
    if not _is-plot-spec(p) {
      panic(
        "compose: every positional argument must be `plot(..., defer: true)`; "
          + "got "
          + repr(p),
      )
    }
  }
  if collect != auto and collect != none and type(collect) != array {
    panic(
      "compose: `collect` must be `auto`, `none`, or an array of aesthetic names",
    )
  }
  if not ("right", "left", "top", "bottom").contains(guides-placement) {
    panic(
      "compose: guides-placement must be \"right\", \"left\", \"top\", or "
        + "\"bottom\"; got "
        + repr(guides-placement),
    )
  }

  context {
    let probes = panels.map(spec => render-plot-deferred(spec))
    let per-panel = probes.map(p => _index-by-aesthetic(p.guides))

    let candidates = if collect == auto {
      let all = ()
      for idx in per-panel {
        for a in idx.keys() {
          if not all.contains(a) { all.push(a) }
        }
      }
      all
    } else if collect == none {
      ()
    } else {
      collect
    }

    let hoisted = ()
    let hoisted-guides = ()
    for a in candidates {
      if not _all-mergeable(per-panel, a) { continue }
      hoisted.push(a)
      let g = _coerce-placement(per-panel.first().at(a), guides-placement)
      // A merged guide (e.g., colour+fill on the same column) is reached
      // through every aesthetic it carries, so dedup by aesthetic mix.
      if not hoisted-guides.any(h => h.aesthetics == g.aesthetics) {
        hoisted-guides.push(g)
      }
    }

    // The panel butts up against the hoisted legend by passing `tight-sides`
    // to render-plot-deferred. `tight-sides` drops the conservative axis-side
    // floor (1.5 / 1.1 cm) on the hoisted side so the dynamic chrome shrinks
    // to just what the present decorations (axis title on left/bottom, none on
    // top/right) actually need.
    let tight-sides = (guides-placement,)

    let final-panels = if hoisted.len() == 0 {
      probes.map(p => p.content)
    } else {
      panels.map(spec => {
        render-plot-deferred(
          spec,
          suppress-aesthetics: hoisted,
          tight-sides: tight-sides,
        ).content
      })
    }

    let panel-block = if layout == "grid" {
      grid(columns: columns, gutter: gutter, ..final-panels)
    } else if layout == "stack" {
      stack(dir: direction, spacing: gutter, ..final-panels)
    } else {
      panic(
        "compose: layout must be \"grid\" or \"stack\"; got " + repr(layout),
      )
    }

    if hoisted-guides.len() == 0 {
      return panel-block
    }

    let first-theme = panels.first().theme
    let theme = merge-theme(
      if first-theme != none { first-theme } else { _theme-state.get() },
    )
    let trained = probes.first().trained
    let size = _legend-canvas-size(hoisted-guides, guides-placement)
    let legend-canvas = legend-mod.standalone(
      hoisted-guides,
      trained,
      theme,
      guides-placement,
      size.width,
      size.height,
    )
    // For right placement the panel-margin override trims the panel's right
    // side to 0 cm; with no intrinsic cetz padding on that side the legend
    // would butt against the panel data area, so add `legend-gap` to match a
    // single-plot side-legend offset. Other sides leave the panel-block's
    // own axis-text / cetz-baseline padding to provide the visual gap.
    let right-gap = legend-mod.legend-gap(theme) * 1cm

    if guides-placement == "right" {
      grid(
        columns: (auto, auto),
        gutter: right-gap,
        panel-block, legend-canvas,
      )
    } else if guides-placement == "left" {
      grid(
        columns: (auto, auto),
        legend-canvas, panel-block,
      )
    } else if guides-placement == "bottom" {
      stack(dir: ttb, panel-block, align(center, legend-canvas))
    } else {
      stack(dir: ttb, align(center, legend-canvas), panel-block)
    }
  }
}
