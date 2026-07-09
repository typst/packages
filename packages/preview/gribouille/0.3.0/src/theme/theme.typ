///! Custom theme builder.
///!
///! `theme` accepts per-element overrides via named arguments. Keys can be
///! either low-level fields (same names as the internal `default-theme`) or
///! structured element records from \@element-text, \@element-line,
///! \@element-rect, and \@element-blank.
///!
///! Base element keys (`text`, `line`, `rect`) set inherited parent fields:
///! specific child keys (e.g., `axis-text`) take priority at render time.

#import "elements.typ": element-geom
#import "../utils/colour.typ": col-mix
#import "../utils/errors.typ": fail
#import "../utils/margin.typ": (
  resolve-margin-side-cm, resolve-margin-side-rel-cm,
)

#let _surface-parent = {
  let out = (
    "axis-text": "text",
    "axis-title": "text",
    "legend-text": "text",
    "legend-title": "text",
    "strip-text": "text",
    "plot-title": "text",
    "plot-subtitle": "text",
    "plot-caption": "text",
    "plot-tag": "text",
    "panel-grid": "line",
    "axis-line": "line",
    "axis-ticks": "line",
    "legend-ticks": "line",
    "panel-background": "rect",
    "plot-background": "rect",
    "strip-background": "rect",
    "legend-background": "rect",
    "legend-bar": "rect",
  )
  // Each axis family gains per-axis (-x, -y) and per-side (-x-bottom, -x-top,
  // -y-left, -y-right) variants that cascade up to their family.
  for fam in ("axis-text", "axis-title", "axis-line", "axis-ticks") {
    out.insert(fam + "-x", fam)
    out.insert(fam + "-y", fam)
    out.insert(fam + "-x-bottom", fam + "-x")
    out.insert(fam + "-x-top", fam + "-x")
    out.insert(fam + "-y-left", fam + "-y")
    out.insert(fam + "-y-right", fam + "-y")
  }
  out
}

#let _merge-element(base, top) = {
  let out = base
  for (k, v) in top.pairs() {
    if k == "kind" { continue }
    if v == none { continue }
    out.insert(k, v)
  }
  if top.at("kind", default: none) != none {
    out.insert("kind", top.kind)
  }
  out
}

/// Resolve a surface's element record by walking its inheritance chain root-to-leaf and merging in order.
///
/// The cascade follows `_surface-parent` to the root, then merges each populated record back down so the most specific surface wins. Returns a dict shaped like the underlying element constructor, with `kind` set to the most specific element kind in the cascade. Fields not set anywhere remain `none`; the renderer is responsible for hardcoded fallbacks (e.g., colour → `theme.ink`).
///
/// - theme: Merged theme dictionary.
/// - surface: Surface key, e.g., `"axis-text-x-bottom"`, `"panel-grid"`.
///
/// Returns: Element record with cascaded fields.
#let resolve-element(theme, surface) = {
  let chain = ()
  let cur = surface
  while cur != none {
    chain.push(cur)
    cur = _surface-parent.at(cur, default: none)
  }
  let merged = (:)
  for key in chain.rev() {
    let rec = theme.at(key, default: none)
    if rec != none { merged = _merge-element(merged, rec) }
  }
  merged
}

/// Resolve a per-side scalar theme key with a three-step cascade: `<base>-<side>` → `<base>-<axis>` → `<base>`.
///
/// Returns `0pt` if no level of the cascade is set. Used for `tick-length` and any future scalar that mirrors the element cascade shape.
///
/// - theme: Merged theme dictionary.
/// - base: Scalar key root, e.g., `"tick-length"`.
/// - side: Side suffix, e.g., `"x-bottom"`, `"y-right"`.
/// - axis: Axis suffix, `"x"` or `"y"`.
///
/// Returns: The most specific value set, falling back to base, then `0pt`.
#let _scalar-cascade(theme, base, side, axis) = {
  let v = theme.at(base + "-" + side, default: none)
  if v != none { return v }
  let av = theme.at(base + "-" + axis, default: none)
  if av != none { return av }
  theme.at(base, default: 0pt)
}

// Empty layer-default record reused whenever the theme has no `geom` slot
// or carries a non-element-geom record (theme drift, partial user theme).
// Hoisted to module scope so per-render lookups don't re-allocate it.
#let _EMPTY-GEOM-DEFAULTS = element-geom()

// Tint amount for the bar/area/rect/tile-family body fill: a muted grey mix
// of the resolved `ink` and `paper` roles (`0.35` matches `grey35`).
// \@internal
#let fill-tint-amount = 0.35

// \@internal
#let default-stroke-thickness = 0.5pt

// Single source of truth for default inheritance. Per field, the element-geom
// slot wins first (applied in resolve-geom-defaults); if unset, each source is
// tried in order and the first non-`none` result is used.
// Fields absent here carry NO inheritance by design: fill/colour are global
// overrides (`none` = no default); linewidth inherits only its slot, the
// terminal fallback being supplied per-consumer by resolve-geom-linewidth.
// \@internal
#let _geom-default-cascade = (
  ink: (theme => theme.at("ink", default: none), theme => black),
  paper: (theme => theme.at("paper", default: none), theme => white),
  accent: (theme => theme.at("accent", default: none), theme => rgb("#3366FF")),
  font: (theme => resolve-element(theme, "text").at("font", default: none),),
)

/// Resolve `theme.geom` to a fully-resolved layer-defaults dict.
///
/// Returns the shape produced by `element-geom`. Inheritance is declared once in `_geom-default-cascade`: for each listed field the `element-geom` slot wins first, then the theme-level scalar / document value, then a hard fallback. So `ink` / `paper` / `accent` are always concrete; `font` may be `none` (the geom then omits the `text(font: ...)` argument). The fall-through to an empty record keeps rendering robust when a partial user theme drops the `geom` key. `fill` / `colour` / `linewidth` are not in the cascade and stay as their slot value (or `none`); `resolve-geom-colour`, `resolve-geom-fill` and `resolve-geom-linewidth` consume the result.
///
/// - theme: Merged theme dictionary.
///
/// Returns: Element-geom record (always present; cascade fields resolved).
#let resolve-geom-defaults(theme) = {
  let g = theme.at("geom", default: none)
  if g == none or g.at("kind", default: none) != "element-geom" {
    g = _EMPTY-GEOM-DEFAULTS
  }
  for (field, sources) in _geom-default-cascade {
    if g.at(field, default: none) != none { continue }
    for src in sources {
      let v = src(theme)
      if v != none {
        g.insert(field, v)
        break
      }
    }
  }
  g
}

/// Resolve a geom's default stroke/text colour.
///
/// `element-geom.colour` always wins (the global colour override). Otherwise the geom's colour role selects the resolved field: `"ink"` for almost every geom, `"accent"` for `geom-smooth`. Pass `role: none` for filled geoms that draw no outline by default (bar/area/ribbon/rect/tile/hex) so the absence of an outline survives until the user maps `colour` or pins `element-geom.colour`.
///
/// - defaults: Element-geom record from `resolve-geom-defaults`.
/// - role: Colour role key: `"ink"`, `"accent"`, or `none`.
///
/// Returns: A colour or `none`.
#let resolve-geom-colour(defaults, role: "ink") = {
  let v = defaults.at("colour", default: none)
  if v != none { return v }
  if role == none { return none }
  if role == "ink" or role == "accent" { return defaults.at(role) }
  fail("resolve-geom-colour", "unknown role " + repr(role))
}

/// Resolve a geom's default body fill.
///
/// `element-geom.fill` always wins (the global fill override). Otherwise the geom's fill role selects from the resolved record:
///
/// - `"tint"`: `col-mix(ink, paper, fill-tint-amount)` for the bar / area / rect / tile family;
/// - `"paper"`: the paper role (`geom-boxplot`, `geom-crossbar`, `geom-point`, `geom-label`);
/// - `"ink"`: the ink role (`geom-dotplot`).
///
/// - defaults: Element-geom record from `resolve-geom-defaults`.
/// - role: Fill role key: `"tint"`, `"paper"`, or `"ink"`.
///
/// Returns: A colour.
#let resolve-geom-fill(defaults, role: "tint") = {
  let v = defaults.at("fill", default: none)
  if v != none { return v }
  if role == "tint" {
    return col-mix(defaults.ink, defaults.paper, fill-tint-amount)
  }
  if role == "paper" or role == "ink" { return defaults.at(role) }
  fail("resolve-geom-fill", "unknown role " + repr(role))
}

/// Resolve the geom `linewidth` default: `element-geom.linewidth` if set, else the caller-supplied `fallback` (`default-stroke-thickness` by default).
///
/// - defaults: Element-geom record from `resolve-geom-defaults`.
/// - fallback: Length returned when the slot is unset.
///
/// Returns: A length.
#let resolve-geom-linewidth(defaults, fallback: default-stroke-thickness) = {
  let v = defaults.at("linewidth", default: none)
  if v != none { v } else { fallback }
}

// Sentinel shared by text and rect element normalisation; every side `auto`
// so the consumption site supplies its own fallback.
#let _empty-margin = (
  kind: "margin",
  top: auto,
  right: auto,
  bottom: auto,
  left: auto,
)

#let _zero-margin-cm = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)

// Resolve a normalised margin record to per-side cm floats. Top / bottom
// reference `ref-h`; left / right reference `ref-w`; both are cm floats
// used as the `100%` denominator for `ratio` / `relative` sides. Absolute
// and em values ignore the references and resolve against `size-pt`.
#let _margin-to-cm(margin, ref-w, ref-h, size-pt) = (
  top: resolve-margin-side-rel-cm(margin.top, ref-h, size-pt: size-pt),
  right: resolve-margin-side-rel-cm(margin.right, ref-w, size-pt: size-pt),
  bottom: resolve-margin-side-rel-cm(margin.bottom, ref-h, size-pt: size-pt),
  left: resolve-margin-side-rel-cm(margin.left, ref-w, size-pt: size-pt),
)

// Look up the theme's base text size in pt; falls back to 9 when the
// `text` surface is absent (partial user theme).
#let _theme-size-pt(theme) = {
  let text-el = theme.at("text", default: none)
  if (
    type(text-el) == dictionary and text-el.at("size", default: none) != none
  ) { text-el.size / 1pt } else { 9 }
}

// Normalise a `margin` field to the four-side dict shape the renderer
// expects. Accepts `none`, a `margin(...)` record, or any other value
// (treated as `none`). Missing sides default to `auto`.
#let _normalise-margin(value) = {
  if (
    value == none
      or type(value) != dictionary
      or value.at("kind", default: none) != "margin"
  ) {
    return _empty-margin
  }
  (
    kind: "margin",
    top: value.at("top", default: auto),
    right: value.at("right", default: auto),
    bottom: value.at("bottom", default: auto),
    left: value.at("left", default: auto),
  )
}

/// Resolve a text surface into a flat dict ready for `text(...)` arguments.
///
/// - theme: Merged theme dictionary.
/// - surface: Text surface key, e.g., `"axis-text"`.
///
/// Returns: Dict with `size`, `fill`, `weight`, `font`, `typst`, `margin`, `align`.
#let _text-style(theme, surface) = {
  let el = resolve-element(theme, surface)
  let blank = el.at("kind", default: none) == "element-blank"
  let colour = el.at("colour", default: none)
  let weight = el.at("weight", default: none)
  (
    // `element-blank()` collapses the surface: a `0pt` size makes every
    // consumer that gates on `size > 0pt` skip both ink and reserved space.
    size: if blank { 0pt } else { el.at("size", default: 9pt) },
    fill: if colour != none { colour } else { theme.ink },
    weight: if weight != none { weight } else { "regular" },
    // `none` when unset; consumers omit the `text(font: ...)` argument so the
    // document font is kept. Cascades up the surface chain like every field.
    font: el.at("font", default: none),
    typst: el.at("kind", default: none) == "element-typst",
    margin: _normalise-margin(el.at("margin", default: none)),
    // `none` when unset; each draw site applies its per-surface default.
    align: el.at("align", default: none),
    // `none` when unset; text surfaces rotate their drawn content by this
    // angle, and axis-text feeds it as the tick-label angle default.
    angle: el.at("angle", default: none),
  )
}

/// Build the base `text(...)` argument dict for a resolved text style, threading the font only when one is set (Typst's `font` rejects `none`). Spread into `text(..., body)` and merge with per-site extras.
///
/// - style: Resolved text-style dict from `_text-style`.
///
/// Returns: Dict with `size`, `fill`, `weight`, and `font` when set.
#let _text-args(style) = {
  let args = (size: style.size, fill: style.fill, weight: style.weight)
  if style.font != none { args.insert("font", style.font) }
  args
}

/// Resolve a line surface into a stroke dict, or `none` for `element-blank`.
///
/// - theme: Merged theme dictionary.
/// - surface: Line surface key, e.g., `"panel-grid"`.
/// - fallback-colour: Colour used when neither surface nor parent set one.
///
/// Returns: Stroke dict `(paint, thickness)`, or `none` to skip drawing.
#let _line-stroke(theme, surface, fallback-colour: none) = {
  let el = resolve-element(theme, surface)
  if el.at("kind", default: none) == "element-blank" { return none }
  let colour = el.at("colour", default: none)
  let thickness = el.at("stroke", default: none)
  if thickness == 0pt { return none }
  let paint = if colour != none {
    colour
  } else if fallback-colour != none {
    fallback-colour
  } else { theme.ink }
  (
    paint: paint,
    thickness: if thickness != none { thickness } else {
      default-stroke-thickness
    },
  )
}

/// Resolve a rect surface into a fill colour, outline stroke, and per-side cm margins. `inset-cm` is consumed by cetz draw sites (positive values grow the painted rectangle outward from its natural bound as inner padding); `%` / `relative` sides reference the rect's own natural dimension (`inset-ref-w` / `inset-ref-h`), so a 5% inset on a 5cm-wide panel paints 0.25cm of breathing room and never overflows onto a neighbour. `outset-cm` is consumed by layout reservation upstream of the cetz canvas (positive values reserve outer whitespace eaten from the panel canvas); `%` / `relative` sides reference the plot canvas (`outset-ref-w` / `outset-ref-h`). Raw `inset` / `outset` `margin` records are also exposed for plot-background, which maps them onto Typst `block(inset:)` / `pad()`.
///
/// - theme: Merged theme dictionary.
/// - surface: Rect surface key, e.g., `"panel-background"`.
/// - fallback-fill: Fill used when neither surface nor parent sets one.
/// - fallback-colour: Outline paint used when only a thickness is set.
/// - inset-ref-w: Horizontal reference for `inset` `%` sides; should be the rect's own natural width in cm. Defaults to `0`.
/// - inset-ref-h: Vertical reference for `inset` `%` sides; should be the rect's own natural height in cm. Defaults to `0`.
/// - outset-ref-w: Horizontal reference for `outset` `%` sides; should be the plot canvas width in cm. Defaults to `0`.
/// - outset-ref-h: Vertical reference for `outset` `%` sides; should be the plot canvas height in cm. Defaults to `0`.
///
/// Returns: Dict `(fill, stroke, inset-cm, outset-cm, inset, outset)`.
#let _rect-style(
  theme,
  surface,
  fallback-fill: none,
  fallback-colour: none,
  inset-ref-w: 0,
  inset-ref-h: 0,
  outset-ref-w: 0,
  outset-ref-h: 0,
) = {
  let el = resolve-element(theme, surface)
  let inset = _normalise-margin(el.at("inset", default: none))
  let outset = _normalise-margin(el.at("outset", default: none))
  // Default cascade leaves both records empty; skip cm resolution and the
  // `theme.text.size` lookup in that hot path.
  let inset-cm = if inset == _empty-margin {
    _zero-margin-cm
  } else {
    _margin-to-cm(inset, inset-ref-w, inset-ref-h, _theme-size-pt(theme))
  }
  let outset-cm = if outset == _empty-margin {
    _zero-margin-cm
  } else {
    _margin-to-cm(outset, outset-ref-w, outset-ref-h, _theme-size-pt(theme))
  }
  if el.at("kind", default: none) == "element-blank" {
    return (
      fill: none,
      stroke: none,
      inset-cm: inset-cm,
      outset-cm: outset-cm,
      inset: inset,
      outset: outset,
    )
  }
  let fill = el.at("fill", default: none)
  let colour = el.at("colour", default: none)
  let thickness = el.at("stroke", default: none)
  let stroke = if thickness == 0pt or (colour == none and thickness == none) {
    none
  } else {
    let paint = if colour != none {
      colour
    } else if fallback-colour != none {
      fallback-colour
    } else { theme.ink }
    (
      paint: paint,
      thickness: if thickness != none { thickness } else {
        default-stroke-thickness
      },
    )
  }
  (
    fill: if fill != none { fill } else { fallback-fill },
    stroke: stroke,
    inset-cm: inset-cm,
    outset-cm: outset-cm,
    inset: inset,
    outset: outset,
  )
}

/// Resolve a rect surface's `outset` to per-side cm floats only. Leaner than `_rect-style` for layout-reservation sites that only need the reserved outer-margin slot, not the fill/stroke or inset. `%` sides reference the plot canvas (`ref-w` / `ref-h`).
///
/// - theme: Merged theme dictionary.
/// - surface: Rect surface key.
/// - ref-w: Horizontal canvas reference (cm float) used as `100%` for ratio / relative sides.
/// - ref-h: Vertical canvas reference (cm float).
///
/// Returns: Dict `(top, right, bottom, left)` of cm floats, zero on every side when no outset is set.
#let _rect-outset-cm(theme, surface, ref-w: 0, ref-h: 0) = {
  let el = resolve-element(theme, surface)
  let outset = _normalise-margin(el.at("outset", default: none))
  if outset == _empty-margin { return _zero-margin-cm }
  _margin-to-cm(outset, ref-w, ref-h, _theme-size-pt(theme))
}

#let _apply-element(out, key, value) = {
  if value == none { return out }
  // Element records (text / line / rect / blank / typst) and bare scalars
  // both pass through verbatim. The renderer queries records via
  // `resolve-element`.
  out.insert(key, value)
  out
}

#let _apply-overrides(out, fields) = {
  for (k, v) in fields.named().pairs() {
    out = _apply-element(out, k, v)
  }
  out
}

/// Build a theme preset from a name and a surfaces dict, then apply user overrides.
///
/// `surfaces` is a flat dict whose keys match the theme's structured fields (`panel-background`, `panel-grid`, `axis-line`, `axis-text`, ...). `none`-valued surfaces are dropped so presets can declare "no override here" inline without polluting the resulting theme dict.
///
/// - name: Preset display name (`"grey"`, `"bw"`, ...).
/// - ink: Foreground colour.
/// - paper: Background colour.
/// - accent: Accent colour.
/// - surfaces: Dict of surface keys to element records.
/// - fields: Rest-binding capture forwarded from the preset constructor.
///
/// Returns: A theme dict ready for the renderer.
#let _preset(name, ink, paper, accent, surfaces, fields) = {
  let base = (
    kind: "theme",
    name: name,
    ink: ink,
    paper: paper,
    accent: accent,
  )
  for (k, v) in surfaces.pairs() {
    if v == none { continue }
    base.insert(k, v)
  }
  _apply-overrides(base, fields)
}

/// Build a custom theme from per-element overrides.
///
/// Pass named arguments like `axis-title: element-text(size: 12pt)` or `panel-grid: element-blank()`. Each surface is stored as an element record; the renderer reads them via `resolve-element` with cascade `surface → parent → defaults`.
///
/// The table below is the full catalogue of accepted keys. Each row lists the key, its accepted type, the default applied when unset, and the parent it inherits from (root rows are at the top of an inheritance chain). Children with `inherits` for the default fall back through the parent chain until a default is found. Rows are grouped by family.
///
/// - fields: Named per-element overrides; see the description above for the full catalogue of structured and flat keys.
///   - text: Override for the `text` element.
///   - line: Override for the `line` element.
///   - rect: Override for the `rect` element.
///   - plot-title: Override for the `plot-title` element.
///   - plot-subtitle: Override for the `plot-subtitle` element.
///   - plot-caption: Override for the `plot-caption` element.
///   - plot-tag: Override for the `plot-tag` element.
///   - plot-background: Override for the `plot-background` element.
///   - axis-title: Override for the `axis-title` element.
///   - axis-text: Override for the `axis-text` element.
///   - axis-line: Override for the `axis-line` element.
///   - axis-ticks: Override for the `axis-ticks` element.
///   - panel-grid: Override for the `panel-grid` element.
///   - panel-background: Override for the `panel-background` element.
///   - legend-title: Override for the `legend-title` element.
///   - legend-text: Override for the `legend-text` element.
///   - legend-ticks: Override for the `legend-ticks` element.
///   - legend-background: Override for the `legend-background` element.
///   - legend-bar: Override for the `legend-bar` element.
///   - strip-text: Override for the `strip-text` element.
///   - strip-background: Override for the `strip-background` element.
///   - geom: Override for the `geom` element.
///
/// Returns: Theme dictionary consumed by `plot`.
///
/// See the package reference for the full theme key catalogue.
///
/// See also: `theme-grey`, `theme-minimal`, `theme-classic`, `theme-void`, `element-text`, `element-line`, `element-rect`, `element-blank`, `margin`.
///
/// Custom panel and grid colours via structured element records.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     text: element-text(colour: rgb("#2c3e50")),
///     panel-background: element-rect(fill: rgb("#f7f0e7")),
///     panel-grid: element-line(colour: rgb("#d9cfbf")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Hide elements entirely with `element-blank`, useful for very minimalist figures.
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     panel-grid: element-blank(),
///     axis-line: element-blank(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Tweak the scalar fields: bigger ticks, hidden tick labels, and a tinted panel background padded via `element-rect`'s `inset` (inner padding).
///
/// ```typst
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(y: "Cumulative Response (Per Protocol)"),
///   theme: theme(
///     tick-length: 0.25cm,
///     tick-labels: false,
///     panel-background: element-rect(
///       fill: rgb("#f7f0e7"),
///       inset: margin(top: 0.4cm, right: 0.4cm, bottom: 0.4cm, left: 0.4cm),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Set fonts per surface: a base `text` font every text surface inherits, a distinct font for the plot title, and an `element-geom` `font` role for the text-drawing geoms.
///
/// ```typst
/// #let d = range(0, 6).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt), geom-text(mapping: aes(label: "x"))),
///   labs: labs(title: "Fonts", x: "X", y: "Y"),
///   theme: theme(
///     text: element-text(font: "New Computer Modern"),
///     plot-title: element-text(font: "DejaVu Sans Mono"),
///     geom: element-geom(font: "New Computer Modern"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let theme(..fields) = {
  let out = (kind: "theme", name: "custom")
  _apply-overrides(out, fields)
}
