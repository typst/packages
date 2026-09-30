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
    "panel-grid": "line",
    "axis-line": "line",
    "axis-ticks": "line",
    "legend-ticks": "line",
    "panel-background": "rect",
    "plot-background": "rect",
    "strip-background": "rect",
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
/// The cascade follows `_surface-parent` to the root, then merges each populated record back down so the most specific surface wins.
/// Returns a dict shaped like the underlying element constructor, with `kind` set to the most specific element kind in the cascade.
/// Fields not set anywhere remain `none`; the renderer is responsible for hardcoded fallbacks (e.g., colour → `theme.ink`).
///
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param surface Surface key, e.g., `"axis-text-x-bottom"`, `"panel-grid"`.
/// \@returns Element record with cascaded fields.
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
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param base Scalar key root, e.g., `"tick-length"`.
///
/// \@param side Side suffix, e.g., `"x-bottom"`, `"y-right"`.
///
/// \@param axis Axis suffix, `"x"` or `"y"`.
/// \@returns The most specific value set, falling back to base, then `0pt`.
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
#let geom-fill-tint-amount = 0.35

// \@internal
#let default-stroke-thickness = 0.5pt

/// Resolve `theme.geom` to a flat layer-defaults dict.
///
/// Returns the shape produced by \@element-geom; `none` slots leave per-geom
/// fallbacks intact. The fall-through to an empty record is deliberate —
/// keeps rendering robust when a partial user theme drops the `geom` key.
/// `ink` / `paper` / `accent` slots inherit the theme-level scalars when
/// `element-geom` left them unset, mirroring plotnine's role-oriented
/// defaults; \@geom-colour-default and \@geom-fill-default consume them.
/// Geoms resolve once at layer setup and consult the fields they support.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@returns Element-geom record (always present; defaults are all `none`).
#let geom-defaults(theme) = {
  let g = theme.at("geom", default: none)
  if g == none or g.at("kind", default: none) != "element-geom" {
    g = _EMPTY-GEOM-DEFAULTS
  }
  for role in ("ink", "paper", "accent") {
    if g.at(role, default: none) == none {
      g.insert(role, theme.at(role, default: none))
    }
  }
  g
}

/// Pick a `theme.geom` field, falling back when the slot is `none`.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
///
/// \@param field Field name to read (e.g., `"fill"`, `"colour"`, `"linewidth"`).
///
/// \@param fallback Value returned when the slot is unset.
/// \@returns The slot value or the fallback.
#let geom-default(defaults, field, fallback) = {
  let v = defaults.at(field, default: none)
  if v != none { v } else { fallback }
}

/// Resolve the geom `ink` role: `element-geom.ink` if set, else `black`.
///
/// `defaults.ink` already inherits `theme.ink` (see \@geom-defaults), so a
/// `none` here means the theme carried no `ink` either.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
/// \@returns A colour.
#let geom-ink(defaults) = geom-default(defaults, "ink", black)

/// Resolve the geom `paper` role: `element-geom.paper` if set, else `white`.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
/// \@returns A colour.
#let geom-paper(defaults) = geom-default(defaults, "paper", white)

/// Resolve the geom `accent` role: `element-geom.accent` if set, else a
/// defensive `rgb("#3366FF")`.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
/// \@returns A colour.
#let geom-accent(defaults) = geom-default(defaults, "accent", rgb("#3366FF"))

/// Resolve the geom `linewidth` default: `element-geom.linewidth` if set,
/// else \@default-stroke-thickness.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
/// \@returns A length.
#let geom-linewidth(defaults) = geom-default(
  defaults,
  "linewidth",
  default-stroke-thickness,
)

/// Resolve a geom's default stroke/text colour.
///
/// `element-geom.colour` always wins (the global colour override). Otherwise
/// the geom's colour role applies: `"ink"` for almost every geom, `"accent"`
/// for \@geom-smooth. Pass `role: none` for filled geoms that draw no outline
/// by default (bar/area/ribbon/rect/tile/hex) so the absence of an outline
/// survives until the user maps `colour` or pins `element-geom.colour`.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
///
/// \@param role Colour role key: `"ink"`, `"accent"`, or `none`.
/// \@returns A colour or `none`.
#let geom-colour-default(defaults, role: "ink") = {
  let v = defaults.at("colour", default: none)
  if v != none { return v }
  if role == none { return none }
  if role == "ink" { return geom-ink(defaults) }
  if role == "accent" { return geom-accent(defaults) }
  panic("geom-colour-default: unknown role " + role)
}

/// Resolve a geom's default body fill.
///
/// `element-geom.fill` always wins (the global fill override). Otherwise the
/// geom's fill role applies:
/// - `"tint"`: `col-mix(ink, paper, geom-fill-tint-amount)` for the bar /
///   area / rect / tile family;
/// - `"paper"`: the paper role (\@geom-boxplot, \@geom-crossbar, \@geom-point,
///   \@geom-label);
/// - `"ink"`: the ink role (\@geom-dotplot).
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
///
/// \@param role Fill role key: `"tint"`, `"paper"`, or `"ink"`.
/// \@returns A colour.
#let geom-fill-default(defaults, role: "tint") = {
  let v = defaults.at("fill", default: none)
  if v != none { return v }
  if role == "tint" {
    return col-mix(
      geom-ink(defaults),
      geom-paper(defaults),
      geom-fill-tint-amount,
    )
  }
  if role == "paper" { return geom-paper(defaults) }
  if role == "ink" { return geom-ink(defaults) }
  panic("geom-fill-default: unknown role " + role)
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
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param surface Text surface key, e.g., `"axis-text"`.
/// \@returns Dict with `size`, `fill`, `weight`, `typst`, `margin`.
#let _text-style(theme, surface) = {
  let el = resolve-element(theme, surface)
  let colour = el.at("colour", default: none)
  let weight = el.at("weight", default: none)
  (
    size: el.at("size", default: 9pt),
    fill: if colour != none { colour } else { theme.ink },
    weight: if weight != none { weight } else { "regular" },
    typst: el.at("kind", default: none) == "element-typst",
    margin: _normalise-margin(el.at("margin", default: none)),
  )
}

/// Resolve a line surface into a stroke dict, or `none` for `element-blank`.
///
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param surface Line surface key, e.g., `"panel-grid"`.
///
/// \@param fallback-colour Colour used when neither surface nor parent set one.
/// \@returns Stroke dict `(paint, thickness)`, or `none` to skip drawing.
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

/// Resolve a rect surface into a fill colour, outline stroke, and per-side
/// cm margins. `inset-cm` is consumed by cetz draw sites (positive values
/// grow the painted rectangle outward from its natural bound as inner
/// padding); `%` / `relative` sides reference the rect's own natural
/// dimension (`inset-ref-w` / `inset-ref-h`), so a 5% inset on a 5cm-wide
/// panel paints 0.25cm of breathing room and never overflows onto a
/// neighbour. `outset-cm` is consumed by layout reservation upstream of
/// the cetz canvas (positive values reserve outer whitespace eaten from
/// the panel canvas); `%` / `relative` sides reference the plot canvas
/// (`outset-ref-w` / `outset-ref-h`). Raw `inset` / `outset` \@margin
/// records are also exposed for plot-background, which maps them onto
/// Typst `block(inset:)` / `pad()`.
///
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param surface Rect surface key, e.g., `"panel-background"`.
///
/// \@param fallback-fill Fill used when neither surface nor parent sets one.
///
/// \@param fallback-colour Outline paint used when only a thickness is set.
///
/// \@param inset-ref-w Horizontal reference for `inset` `%` sides; should be the rect's own natural width in cm. Defaults to `0`.
///
/// \@param inset-ref-h Vertical reference for `inset` `%` sides; should be the rect's own natural height in cm. Defaults to `0`.
///
/// \@param outset-ref-w Horizontal reference for `outset` `%` sides; should be the plot canvas width in cm. Defaults to `0`.
///
/// \@param outset-ref-h Vertical reference for `outset` `%` sides; should be the plot canvas height in cm. Defaults to `0`.
/// \@returns Dict `(fill, stroke, inset-cm, outset-cm, inset, outset)`.
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

/// Resolve a rect surface's `outset` to per-side cm floats only. Leaner
/// than `_rect-style` for layout-reservation sites that only need the
/// reserved outer-margin slot, not the fill/stroke or inset. `%` sides
/// reference the plot canvas (`ref-w` / `ref-h`).
///
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param surface Rect surface key.
///
/// \@param ref-w Horizontal canvas reference (cm float) used as `100%` for ratio / relative sides.
///
/// \@param ref-h Vertical canvas reference (cm float).
/// \@returns Dict `(top, right, bottom, left)` of cm floats, zero on every side when no outset is set.
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
/// `surfaces` is a flat dict whose keys match the theme's structured fields
/// (`panel-background`, `panel-grid`, `axis-line`, `axis-text`, ...).
/// `none`-valued surfaces are dropped so presets can declare "no override
/// here" inline without polluting the resulting theme dict.
///
/// \@internal
/// \@param name Preset display name (`"grey"`, `"bw"`, ...).
///
/// \@param ink Foreground colour.
///
/// \@param paper Background colour.
///
/// \@param accent Accent colour.
///
/// \@param surfaces Dict of surface keys to element records.
///
/// \@param fields Rest-binding capture forwarded from the preset constructor.
/// \@returns A theme dict ready for the renderer.
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
/// \@theme-keys
///
/// \@category Themes
/// \@subcategory Modify a theme
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ..fields Named per-element overrides; see the description above for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Custom panel and grid colours via structured element records.
/// ```
/// //| alt: "Scatter plot of y against x on a custom theme with navy text, a warm cream panel and pale stone gridlines via element records."
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
/// \@examples Hide elements entirely with \@element-blank, useful for very
/// minimalist figures.
/// ```
/// //| alt: "Scatter plot of y against x with the panel grid and axis lines hidden via element-blank for a stripped-back minimalist figure."
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
/// \@examples Tweak the scalar fields: bigger ticks, hidden tick labels, and a
/// tinted panel background padded via `element-rect`'s `inset` (inner padding).
/// ```
/// //| alt: "Scatter plot of cumulative response against x with longer 0.25cm ticks, hidden tick labels and a panel-background rect grown 0.4cm on every side via element-rect inset (inner padding)."
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
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-void, \@element-text, \@element-line, \@element-rect, \@element-blank, \@margin
#let theme(..fields) = {
  let out = (kind: "theme", name: "custom")
  _apply-overrides(out, fields)
}
