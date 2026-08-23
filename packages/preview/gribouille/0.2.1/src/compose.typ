#import "render.typ": (
  _decorate-extents, _decorate-parts, _render-decorate, render-plot-deferred,
)
#import "legend.typ" as legend-mod
#import "theme/current.typ": _theme-state
#import "theme/defaults.typ": merge-theme
#import "theme/theme.typ": _text-style
#import "theme/elements.typ": margin

// The public `compose` parameter `layout` shadows Typst's builtin `layout`
// function inside the body; capture the builtin here so the container size is
// still reachable.
#let _layout = layout

// Fallback canvas size when the composition sits in an unbounded container
// (e.g., a `width: auto`, `height: auto` page): compose always resolves to a
// concrete size so panels fill their cells rather than keeping their own
// declared dimensions.
#let _DEFAULT-WIDTH = 16cm
#let _DEFAULT-HEIGHT = 12cm

#let _is-plot-spec(x) = (
  type(x) == dictionary
    and "layers" in x
    and "data" in x
    and "width" in x
    and "height" in x
    and "guides" in x
)

#let _is-compose-spec(x) = (
  type(x) == dictionary and x.at("kind", default: none) == "compose"
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

// Overlay compose-level `guides` (including a `default` entry) onto a panel's
// own guides for the probe pass, so the collected legend reflects the
// composition's guide settings while the panels keep their own for
// non-collected aesthetics.
#let _merge-guides(base, extra) = {
  let out = base
  for (k, v) in extra { out.insert(k, v) }
  out
}

// Spreadsheet-style letters for a 0-based index: 0 -> A, 25 -> Z, 26 -> AA.
#let _alpha-symbol(index, upper) = {
  let base = if upper { 65 } else { 97 }
  let out = ""
  let n = index
  while n >= 0 {
    out = str.from-unicode(base + calc.rem(n, 26)) + out
    n = calc.quo(n, 26) - 1
  }
  out
}

// Uppercase Roman numeral for a positive integer.
#let _roman-symbol(num) = {
  let table = (
    (1000, "M"),
    (900, "CM"),
    (500, "D"),
    (400, "CD"),
    (100, "C"),
    (90, "XC"),
    (50, "L"),
    (40, "XL"),
    (10, "X"),
    (9, "IX"),
    (5, "V"),
    (4, "IV"),
    (1, "I"),
  )
  let out = ""
  let n = num
  for (value, sym) in table {
    while n >= value {
      out += sym
      n -= value
    }
  }
  out
}

// Tag symbol for a 0-based panel index under a `tag-levels` code:
// `"A"`/`"a"` latin, `"1"` arabic, `"I"`/`"i"` roman.
#let _tag-symbol(code, index) = {
  if code == "1" {
    str(index + 1)
  } else if code == "A" {
    _alpha-symbol(index, true)
  } else if code == "a" {
    _alpha-symbol(index, false)
  } else if code == "I" {
    _roman-symbol(index + 1)
  } else if code == "i" {
    lower(_roman-symbol(index + 1))
  } else {
    panic(
      "compose: tag-levels code must be \"A\", \"a\", \"1\", \"I\", or "
        + "\"i\"; got "
        + repr(code),
    )
  }
}

#let _TAG-CORNERS = ("top-left", "top-right", "bottom-left", "bottom-right")

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

// Split `total` cm into `count` track lengths separated by `gutter` cm gaps,
// distributed by `ratios` (relative weights) or equally when `ratios` is
// `none`. Returns an array of cm floats summing to `total - gutter * (count -
// 1)`.
#let _tracks(total, count, gutter, ratios) = {
  let usable = calc.max(total - gutter * (count - 1), 0.0)
  let weights = if ratios == none {
    range(count).map(_ => 1.0)
  } else {
    ratios.map(r => float(r))
  }
  let sum = weights.fold(0.0, (a, b) => a + b)
  weights.map(w => usable * w / sum)
}

// Render a compose spec into content at `container` size; `container.width` /
// `.height` are always concrete lengths (`float.inf` for an unbounded page),
// never `auto`. Recurses for nested compose panels. Split out from `compose` so
// a deferred compose spec can be rendered as a panel of another composition.
#let _render-compose(spec, container) = {
  let panels = spec.panels
  let layout = spec.layout
  let columns = spec.columns
  let direction = spec.direction
  let gutter = spec.gutter
  let widths = spec.widths
  let heights = spec.heights
  let width = spec.width
  let height = spec.height
  let collect = spec.collect
  let guides = spec.guides
  let labs = spec.labs
  let alt = spec.alt
  let align-panels = spec.at("align-panels", default: false)
  let tag-ctx = spec.at("tag-ctx", default: none)

  let first-theme = panels.first().theme
  let theme = merge-theme(
    if first-theme != none { first-theme } else { _theme-state.get() },
  )

  // Probe only plot panels with compose-level `guides` merged in; a nested
  // compose collects its own guides internally (guide collection is per level),
  // so it contributes none here and never hoists.
  let probes = panels.map(p => if _is-plot-spec(p) {
    render-plot-deferred((..p, guides: _merge-guides(p.guides, guides)))
  } else { none })
  let per-panel = probes.map(p => if p == none { (:) } else {
    _index-by-aesthetic(p.guides)
  })

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
    let g = per-panel.first().at(a)
    if not hoisted-guides.any(h => h.aesthetics == g.aesthetics) {
      hoisted-guides.push(g)
    }
  }

  // The collected legend's side comes from the (merged) guides; every hoisted
  // guide must agree on it.
  let legend-side = none
  for g in hoisted-guides {
    let s = g.placement.side
    if legend-side == none {
      legend-side = s
    } else if legend-side != s {
      panic(
        "compose: collected guides resolve to different sides ("
          + repr(legend-side)
          + " vs "
          + repr(s)
          + "); set a shared side with "
          + "`guides(default: guide-legend(position: ...))`",
      )
    }
  }
  if (
    legend-side != none
      and not ("right", "left", "top", "bottom").contains(legend-side)
  ) {
    panic(
      "compose: a collected legend must sit on \"right\", \"left\", \"top\", "
        + "or \"bottom\"; got "
        + repr(legend-side),
    )
  }

  // Tag descent: a nested compose inherits the ancestor's `tag-ctx` (levels,
  // separator, affixes, corner, and the accumulated prefix); a top-level
  // compose uses its own params, normalising `tag-levels` to an array.
  let effective-levels = if tag-ctx != none {
    tag-ctx.levels
  } else if spec.tag-levels == none {
    ()
  } else if type(spec.tag-levels) == array {
    spec.tag-levels
  } else {
    (spec.tag-levels,)
  }
  let eff-sep = if tag-ctx != none { tag-ctx.sep } else { spec.tag-sep }
  let eff-prefix = if tag-ctx != none { tag-ctx.prefix } else { "" }
  let eff-tag-prefix = if tag-ctx != none {
    tag-ctx.tag-prefix
  } else { spec.tag-prefix }
  let eff-tag-suffix = if tag-ctx != none {
    tag-ctx.tag-suffix
  } else { spec.tag-suffix }
  let eff-corner = if tag-ctx != none { tag-ctx.corner } else {
    spec.tag-corner
  }
  let level-code = if effective-levels.len() > 0 {
    effective-levels.first()
  } else { none }

  let tag-style = _text-style(theme, "plot-tag")
  // A tag claims its own horizontal band so it never overlaps the panel. The
  // band sits at the tagged corner's vertical edge (top / bottom) and aligns the
  // label to its horizontal edge (left / right). `0.15cm` is the inset around the
  // label and doubles as the gap between the band and the panel.
  let tag-active = level-code != none and tag-style.size > 0pt
  let is-top = eff-corner == "top-left" or eff-corner == "top-right"
  let halign = if eff-corner == "top-left" or eff-corner == "bottom-left" {
    left
  } else { right }
  let tag-box(label) = pad(0.15cm, text(
    size: tag-style.size,
    fill: tag-style.fill,
    weight: tag-style.weight,
  )[#label])
  let tag-band-cm = if tag-active {
    measure(tag-box("Ag")).height / 1cm
  } else { 0.0 }
  // The band must match the panel's own width, not `100%`: the panel grid is
  // built with content-sized (`auto`) columns, so a `100%`-wide band would make
  // its column greedy and overrun the track sized for the panel content.
  let tag-band(width, label) = box(
    width: width,
    height: tag-band-cm * 1cm,
    align(halign + (if is-top { top } else { bottom }), tag-box(label)),
  )

  // Content height of cell `i` for a `target` height `h`: a tagged cell yields
  // the band's height to it; an untagged cell fills `h`. Shared by the real
  // render and the `align-panels` probe so both measure the same geometry.
  let cell-content-h(i, h) = {
    let symbol = if level-code != none { _tag-symbol(level-code, i) } else {
      none
    }
    if tag-active and symbol != none {
      calc.max(h - tag-band-cm, 0.0)
    } else { h }
  }

  // Render one panel (leaf plot or nested compose) at `target` `(w, h)` cm. The
  // panel's own declared width/height are discarded so it fills its cell.
  let make-cell(panel, i, target, margin-override) = {
    let symbol = if level-code != none {
      _tag-symbol(level-code, i)
    } else { none }
    let acc = eff-prefix + (if symbol != none { symbol } else { "" })
    if _is-plot-spec(panel) {
      // Only a panel that actually draws a tag reserves the band; an untagged
      // plot fills the full cell height.
      let cell-tagged = tag-active and symbol != none
      let content-h = cell-content-h(i, target.h)
      let content = render-plot-deferred(
        (..panel, width: target.w * 1cm, height: content-h * 1cm),
        suppress-aesthetics: hoisted,
        margin-override: margin-override,
      ).content
      if not cell-tagged {
        content
      } else {
        let band = tag-band(
          target.w * 1cm,
          eff-tag-prefix + acc + eff-tag-suffix,
        )
        if is-top {
          stack(dir: ttb, band, content)
        } else {
          stack(dir: ttb, content, band)
        }
      }
    } else {
      // Nested compose: descend one tag level (the slot itself is untagged).
      let child = if effective-levels.len() > 0 {
        (
          ..panel,
          tag-ctx: (
            prefix: acc
              + (if effective-levels.len() > 1 { eff-sep } else { "" }),
            levels: if effective-levels.len() > 1 {
              effective-levels.slice(1)
            } else { () },
            sep: eff-sep,
            tag-prefix: eff-tag-prefix,
            tag-suffix: eff-tag-suffix,
            corner: eff-corner,
          ),
        )
      } else { panel }
      _render-compose(child, (width: target.w * 1cm, height: target.h * 1cm))
    }
  }

  // Resolve a concrete canvas size: an explicit length wins, else the bounded
  // container, else the default fallback. Panels always fill the cells carved
  // from this size, so their own declared dimensions are discarded.
  let resolved-width = if width != auto {
    width
  } else if container.width.pt() < float.inf {
    container.width
  } else { _DEFAULT-WIDTH }
  let resolved-height = if height != auto {
    height
  } else if container.height.pt() < float.inf {
    container.height
  } else { _DEFAULT-HEIGHT }
  let deco-parts = if labs != none {
    _decorate-parts(labs, theme, resolved-width / 1cm, resolved-height / 1cm)
  } else { none }
  let deco = if deco-parts != none {
    _decorate-extents(deco-parts)
  } else { (top: 0.0, bottom: 0.0, left: 0.0, right: 0.0) }

  let legend-size = if hoisted-guides.len() > 0 {
    _legend-canvas-size(hoisted-guides, legend-side)
  } else { (width: 0.0, height: 0.0) }
  let right-gap-cm = if legend-side == "right" {
    legend-mod.legend-gap(theme)
  } else { 0.0 }

  let panel-block = {
    let area-w = resolved-width / 1cm - deco.left - deco.right
    let area-h = resolved-height / 1cm - deco.top - deco.bottom
    if legend-side == "right" {
      area-w -= legend-size.width + right-gap-cm
    } else if legend-side == "left" {
      area-w -= legend-size.width
    } else if legend-side == "top" or legend-side == "bottom" {
      area-h -= legend-size.height
    }

    let n = panels.len()
    let cols = 0
    let rows = 0
    let col-ratios = none
    let row-ratios = none
    if layout == "grid" {
      cols = if type(columns) == int { columns } else { columns.len() }
      rows = calc.ceil(n / cols)
      col-ratios = widths
      row-ratios = heights
    } else if direction == ttb or direction == btt {
      if widths != none {
        panic(
          "compose: `widths` has no effect on a vertical stack; size it with "
            + "`heights`",
        )
      }
      cols = 1
      rows = n
      row-ratios = heights
    } else {
      if heights != none {
        panic(
          "compose: `heights` has no effect on a horizontal stack; size it "
            + "with `widths`",
        )
      }
      cols = n
      rows = 1
      col-ratios = widths
    }
    if col-ratios != none and col-ratios.len() != cols {
      panic(
        "compose: `widths` needs one entry per column ("
          + str(cols)
          + "); got "
          + str(col-ratios.len()),
      )
    }
    if row-ratios != none and row-ratios.len() != rows {
      panic(
        "compose: `heights` needs one entry per row ("
          + str(rows)
          + "); got "
          + str(row-ratios.len()),
      )
    }

    let gutter-cm = gutter / 1cm
    let col-tracks = _tracks(area-w, cols, gutter-cm, col-ratios)
    let row-tracks = _tracks(area-h, rows, gutter-cm, row-ratios)

    // `align-panels`: probe each plot panel at the size of the cell it will
    // occupy, then share margins grid-wise so plot areas line up: left/right per
    // column, top/bottom per row (patchwork/cowplot). Nested composes grid-align
    // internally and are skipped.
    let align-margins = if align-panels {
      let col-left = (0.0,) * cols
      let col-right = (0.0,) * cols
      let row-top = (0.0,) * rows
      let row-bottom = (0.0,) * rows
      for (i, panel) in panels.enumerate() {
        if not _is-plot-spec(panel) { continue }
        let col = calc.rem(i, cols)
        let row = calc.quo(i, cols)
        let m = render-plot-deferred(
          (
            ..panel,
            width: col-tracks.at(col) * 1cm,
            height: cell-content-h(i, row-tracks.at(row)) * 1cm,
          ),
          suppress-aesthetics: hoisted,
        ).margin
        col-left.at(col) = calc.max(col-left.at(col), m.left)
        col-right.at(col) = calc.max(col-right.at(col), m.right)
        row-top.at(row) = calc.max(row-top.at(row), m.top)
        row-bottom.at(row) = calc.max(row-bottom.at(row), m.bottom)
      }
      (
        left: col-left,
        right: col-right,
        top: row-top,
        bottom: row-bottom,
      )
    } else { none }

    let cells = ()
    for (i, panel) in panels.enumerate() {
      let col = calc.rem(i, cols)
      let row = calc.quo(i, cols)
      let margin-override = if align-margins == none { none } else {
        (
          left: align-margins.left.at(col),
          right: align-margins.right.at(col),
          top: align-margins.top.at(row),
          bottom: align-margins.bottom.at(row),
        )
      }
      cells.push(make-cell(
        panel,
        i,
        (w: col-tracks.at(col), h: row-tracks.at(row)),
        margin-override,
      ))
    }
    if layout == "grid" {
      grid(columns: cols, gutter: gutter, ..cells)
    } else {
      stack(dir: direction, spacing: gutter, ..cells)
    }
  }

  let composed = if hoisted-guides.len() == 0 {
    panel-block
  } else {
    let trained = probes.find(p => p != none).trained
    let legend-canvas = legend-mod.standalone(
      hoisted-guides,
      trained,
      theme,
      legend-side,
      legend-size.width,
      legend-size.height,
    )
    let right-gap = right-gap-cm * 1cm
    if legend-side == "right" {
      grid(
        columns: (auto, auto),
        align: horizon,
        gutter: right-gap,
        panel-block, legend-canvas,
      )
    } else if legend-side == "left" {
      grid(
        columns: (auto, auto),
        align: horizon,
        legend-canvas, panel-block,
      )
    } else if legend-side == "bottom" {
      stack(dir: ttb, panel-block, align(center, legend-canvas))
    } else {
      stack(dir: ttb, align(center, legend-canvas), panel-block)
    }
  }

  let decorated = if labs == none {
    composed
  } else {
    _render-decorate(composed, deco-parts)
  }

  if alt != none {
    figure(
      pdf.artifact(decorated),
      alt: alt,
      kind: "gribouille-plot",
      supplement: none,
      numbering: none,
      caption: none,
    )
  } else {
    decorated
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
/// \@param widths Relative column widths (grid) or panel widths along a
///   horizontal stack, as an array of weights (e.g., `(2, 1)`). They set the
///   relative cell proportions; panels always fill their cells regardless, so
///   the child plots' own `width`/`height` are discarded either way. Length
///   must match the column count.
///
/// \@param heights Relative row heights (grid) or panel heights along a
///   vertical stack. Same rules as `widths`; length must match the row count.
///
/// \@param width Total composition width. `auto` (default) fills the available
///   width of a bounded container (resolved through Typst `layout`); when the
///   container is unbounded, it falls back to `16cm`. Panels fill the cells
///   carved from this width, so their own declared `width` is discarded.
///
/// \@param height Total composition height. Same semantics as `width`, with a
///   `12cm` fallback when the container is unbounded.
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
/// \@param guides Per-aesthetic guide overrides applied to the collected
///   legend, built with\@guides, exactly as for\@plot. The collected legend's
///   side comes from here: set it per aesthetic via `guide-legend(position:
///   ...)` or for all at once via `guides(default: guide-legend(position:
///   ...))`. All collected guides must resolve to one side, otherwise compose
///   panics. Defaults to the guides' natural side (`"right"`).
///
/// \@param labs Composition-level labels built with\@labs; only `title`,
///   `subtitle`, and `caption` apply (panel-level labels stay on each\@plot).
///   They reuse the same chrome as a single plot, so a composition reads like
///   one figure.
///
/// \@param tag-levels Per-panel tag numbering. A single code numbers this
///   composition's panels in layout order; an array of codes assigns one code
///   per nesting depth: top-level panels take the first code (`A`, `B`, ...)
///   and a nested `compose` panel's own panels continue with the next code,
///   joined by `tag-sep`. So with `("A", "1")` a top-level leaf is `A` while a
///   sibling nested compose (the second panel, `B`) tags its panels `B.1`,
///   `B.2`. Each code is `"A"` / `"a"` (latin), `"1"` (arabic), or `"I"` /
///   `"i"` (roman); `none` (default) draws no tags. When set, this
///   composition's `tag-levels` drives any nested compose and overrides its
///   own.
///
/// \@param tag-prefix String placed before each generated tag symbol (e.g.
///   `"("`).
///
/// \@param tag-suffix String placed after each generated tag symbol (e.g.
///   `")"` or `"."`).
///
/// \@param tag-sep Separator inserted between nested tag levels (e.g., `"."`
///   gives `A.1`). Ignored for a single-level `tag-levels`.
///
/// \@param tag-corner Corner of each panel where its tag sits: `"top-left"`
///   (default), `"top-right"`, `"bottom-left"`, or `"bottom-right"`. Styled by
///   the theme's `plot-tag` element.
///
/// \@param align-panels When `true`, share plot margins grid-wise so plot areas
///   line up: panels in the same column share their left and right margins (the
///   per-column maximum), panels in the same row share their top and bottom
///   margins (the per-row maximum), like `patchwork`/`cowplot` panel alignment.
///   Defaults to `false`, where each panel sizes its own margins from its axis
///   labels and titles. Nested `compose` panels already grid-align internally
///   and are left untouched.
///
/// \@param alt Alt text for the whole composition. When set, the result is
///   wrapped in a `figure` (kind `"gribouille-plot"`) carrying this PDF
///   alternative text, exactly as\@plot does.
///
/// \@param defer When `true`, return a compose spec dict instead of content so
///   this composition can be passed as a panel to another `compose`. Guide
///   collection stays per level (a nested compose draws its own collected
///   legend); only tag numbering descends across nesting.
///
/// \@returns Typst content block: the panel layout with the shared legend and
///   any composition labels, or the bare panel layout when no aesthetic ends up
///   hoisted; wrapped in a `figure` when `alt` is set. Returns a spec dict when
///   `defer: true`.
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
///   guides: guides(default: guide-legend(position: "bottom")),
/// )
/// ```
///
/// \@examples Size the composition to a bounded box and split the two panels
/// 2:1 with `widths`; the child plots' own dimensions are discarded.
/// ```
/// //| alt: "Two mpg scatter panels in a 16 by 6 centimetre canvas where the left panel is twice the width of the right, sharing a colour-by-cylinder legend on the right."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 2pt),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #box(width: 16cm, height: 6cm, compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"))),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"))),
///   columns: 2, widths: (2, 1),
/// ))
/// ```
///
/// \@examples Give the composition its own title and caption with `labs`.
/// ```
/// //| alt: "Two mpg scatter panels under a shared title 'Fuel economy' and a source caption, with a colour-by-cylinder legend on the right."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 2pt),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #box(width: 15cm, height: 7cm, compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"))),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"))),
///   columns: 2,
///   labs: labs(title: "Fuel economy", caption: "Source: mpg"),
/// ))
/// ```
///
/// \@examples Number the panels `(A)`, `(B)`, ... in the top-left corner with
/// a tag pattern.
/// ```
/// //| alt: "Two mpg scatter panels each tagged (A) and (B) in the top-left corner, sharing a colour-by-cylinder legend on the right."
/// #let panel(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 2pt),),
///   width: 6cm, height: 4cm, defer: true,
/// )
/// #box(width: 15cm, height: 5cm, compose(
///   panel(aes(x: "displ", y: "hwy", colour: as-factor("cyl"))),
///   panel(aes(x: "displ", y: "cty", colour: as-factor("cyl"))),
///   columns: 2,
///   tag-levels: "A", tag-prefix: "(", tag-suffix: ")",
/// ))
/// ```
///
/// \@examples Nest a deferred `compose` as a panel; `tag-levels: ("A", "1")`
/// numbers the left leaf panel `A` and the nested column `B.1`, `B.2`.
/// ```
/// //| alt: "A left scatter panel tagged A beside a nested column of two scatter panels tagged B.1 and B.2."
/// #let p(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 2pt),),
///   width: 5cm, height: 3.5cm, defer: true,
/// )
/// #let inner = compose(
///   p(aes(x: "displ", y: "hwy")),
///   p(aes(x: "displ", y: "cty")),
///   columns: 1, defer: true,
/// )
/// #box(width: 14cm, height: 7cm, compose(
///   p(aes(x: "displ", y: "hwy")),
///   inner,
///   columns: 2,
///   tag-levels: ("A", "1"), tag-sep: ".",
/// ))
/// ```
///
/// \@examples Align the panels: `align-panels: true` forces a shared margin so
/// the y axes line up even when the panels' label widths differ.
/// ```
/// //| alt: "Two stacked mpg scatter panels whose y axes are aligned to a common left margin so the plot areas start at the same horizontal position."
/// #let p(map) = plot(
///   data: mpg, mapping: map,
///   layers: (geom-point(size: 2pt),),
///   width: 7cm, height: 3cm, defer: true,
/// )
/// #compose(
///   p(aes(x: "displ", y: "hwy")),
///   p(aes(x: "displ", y: "displ")),
///   columns: 1, align-panels: true,
/// )
/// ```
///
/// \@see\@plot,\@aes,\@guides,\@labs
#let compose(
  ..panels-positional,
  layout: "grid",
  columns: 2,
  direction: ttb,
  gutter: 0.5cm,
  widths: none,
  heights: none,
  width: auto,
  height: auto,
  collect: auto,
  guides: (:),
  labs: none,
  tag-levels: none,
  tag-prefix: "",
  tag-suffix: "",
  tag-sep: "",
  tag-corner: "top-left",
  align-panels: false,
  alt: none,
  defer: false,
) = {
  let panels = panels-positional.pos()
  if panels.len() == 0 {
    panic("compose: at least one deferred plot is required")
  }
  for p in panels {
    if not (_is-plot-spec(p) or _is-compose-spec(p)) {
      panic(
        "compose: every positional argument must be `plot(..., defer: true)` "
          + "or `compose(..., defer: true)`; got "
          + repr(p),
      )
    }
  }
  if collect != auto and collect != none and type(collect) != array {
    panic(
      "compose: `collect` must be `auto`, `none`, or an array of aesthetic names",
    )
  }
  if layout != "grid" and layout != "stack" {
    panic("compose: layout must be \"grid\" or \"stack\"; got " + repr(layout))
  }
  if tag-levels != none {
    let codes = if type(tag-levels) == array { tag-levels } else {
      (tag-levels,)
    }
    for c in codes {
      if not ("A", "a", "1", "I", "i").contains(c) {
        panic(
          "compose: tag-levels codes must be \"A\", \"a\", \"1\", \"I\", or "
            + "\"i\"; got "
            + repr(c),
        )
      }
    }
  }
  if not _TAG-CORNERS.contains(tag-corner) {
    panic(
      "compose: tag-corner must be \"top-left\", \"top-right\", "
        + "\"bottom-left\", or \"bottom-right\"; got "
        + repr(tag-corner),
    )
  }

  let spec = (
    kind: "compose",
    panels: panels,
    layout: layout,
    columns: columns,
    direction: direction,
    gutter: gutter,
    widths: widths,
    heights: heights,
    width: width,
    height: height,
    collect: collect,
    guides: guides,
    labs: labs,
    tag-levels: tag-levels,
    tag-prefix: tag-prefix,
    tag-suffix: tag-suffix,
    tag-sep: tag-sep,
    tag-corner: tag-corner,
    align-panels: align-panels,
    alt: alt,
    tag-ctx: none,
  )
  if defer { return spec }
  _layout(container => context { _render-compose(spec, container) })
}
