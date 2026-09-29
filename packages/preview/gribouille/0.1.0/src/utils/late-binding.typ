///! Late-binding aesthetic markers.
///!
///! Constructors for plotnine late-binding primitives. These
///! markers defer aesthetic resolution past the point where a column was
///! first bound, so callers can pull values from the trained stat output,
///! the resolved scale output, or the active theme.

#let _LATE-BINDING-KINDS = (
  "from-theme",
  "after-stat",
  "after-scale",
  "stage",
)

// Prefix for synthesised columns produced by function-form `after-stat`
// closures. The full column name is `_as_<channel>`; collisions with
// user-supplied column names of this exact shape would be silently
// overwritten, hence the deliberate underscore prefix.
#let _AFTER-STAT-COL-PREFIX = "_as_"

/// Read the late-binding kind tag on a marker, or `none` if `v` is not a
/// late-binding marker.
///
/// \@internal
/// \@param v Any value.
/// \@returns The kind string or `none`.
#let late-binding-kind(v) = {
  if type(v) != dictionary { return none }
  let k = v.at("kind", default: none)
  if k in _LATE-BINDING-KINDS { k } else { none }
}

/// Whether a mapping value is a late-binding marker.
///
/// \@internal
/// \@param v Any value pulled from an aesthetic mapping.
/// \@returns `true` when `v` is a dictionary tagged with one of the
///   late-binding kinds.
#let is-late-binding(v) = late-binding-kind(v) != none

// Humanise a stat output column name for use as an axis or legend title:
// drop the synthetic leading underscores and capitalise the first letter
// (`"_count"` -> `"Count"`, `"_density"` -> `"Density"`). Returns `name`
// unchanged when it is empty after trimming.
#let _stat-label(name) = {
  let trimmed = name.trim("_", at: start)
  if trimmed == "" { return name }
  upper(trimmed.first()) + trimmed.slice(1)
}

/// Display name for a late-binding marker, used by axis and legend title
/// fallbacks. An `after-stat` (or `stage`'s post-stat lane) names a stat
/// output column, surfaced via `_stat-label`; `stage` with no post-stat lane
/// falls back to its `start` column. A closure lane, an `after-scale`, or a
/// `from-theme` marker carries no name, so this returns `none` and the caller
/// should leave the title empty (or take a `labs()` override).
///
/// \@internal
/// \@param v Any value pulled from an aesthetic mapping.
/// \@returns A title string, or `none` when `v` is not a late-binding marker
///   or carries no nameable source.
#let late-binding-name(v) = {
  let kind = late-binding-kind(v)
  if kind == "after-stat" {
    let expr = v.at("expr", default: none)
    return if type(expr) == str { _stat-label(expr) } else { none }
  }
  if kind == "stage" {
    let after-stat-lane = v.at("after-stat", default: none)
    if type(after-stat-lane) == str { return _stat-label(after-stat-lane) }
    let start-lane = v.at("start", default: none)
    return if type(start-lane) == str { start-lane } else { none }
  }
  none
}

/// Pull a value from the resolved theme at render time.
///
/// `path` may be a dotted string (`"axis-line.colour"`) or an array of
/// keys (`("axis-line", "colour")`). Both forms are equivalent.
///
/// `from-theme(...)` resolves at layer prepare time, so the marker is
/// replaced by a literal scalar before scale training and per-row
/// rendering ever see it. Use it on aesthetic channels that have a
/// fixed-value layer parameter (`colour`, `fill`, `size`, `alpha`,
/// `linewidth`, `stroke`, `shape`, `linetype`).
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param path Dotted string or array of keys naming a theme entry.
/// \@returns Late-binding marker consumed by \@aes.
///
/// \@examples Pin a layer's stroke colour to the active theme's `ink`.
/// ```
/// //| alt: "Scatter chart of three points whose marker colour is pinned to the active theme's ink via from-theme."
/// #let d = (
///   (x: 1, y: 2),
///   (x: 2, y: 4),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: from-theme("ink")),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@aes, \@theme
#let from-theme(path) = (kind: "from-theme", path: path)

/// Bind an aesthetic to a column produced by the layer's stat, or to a
/// per-row computation over the post-stat data.
///
/// `expr` may be a string column name (looked up in the post-stat row) or
/// a function `(row, ctx) => any`. `ctx` carries `theme`, `palette`,
/// `stat-name`, and `stat-info` (see `_prepare-layer` for the exact shape).
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param expr Column-name string or `(row, ctx) => any` closure.
/// \@returns Late-binding marker consumed by \@aes.
///
/// \@examples Bind `y` to the `_count` column `geom-bar`'s `stat-count` publishes.
/// ```
/// //| alt: "Bar chart of three categories with bar heights bound to the post-stat _count column via after-stat."
/// #let d = (
///   (grp: "a"), (grp: "b"), (grp: "a"),
///   (grp: "c"), (grp: "a"), (grp: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: after-stat("_count")),
///   layers: (geom-bar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@aes
#let after-stat(expr) = (kind: "after-stat", expr: expr)

/// Transform an aesthetic's resolved value just before it reaches the
/// geom's draw step.
///
/// `expr` receives the channel's scale-resolved value (or the channel
/// default when the channel carries no source) and a context dict
/// (`theme`, `palette`, `trained`, `row`, `resolve-colour`, ...).
/// The closure's return value is what the geom finally draws. Currently
/// honoured on `colour`, `fill`, `alpha`, `size`, `linewidth`, `stroke`,
/// `shape`, and `linetype`. The closure runs once per row.
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param expr Function `(value, ctx) => any`.
/// \@returns Late-binding marker consumed by \@aes.
///
/// \@examples Mirror the trained fill palette into the marker outline and darken it.
/// ```
/// //| alt: "Scatter chart of four points whose marker outline mirrors the fill palette darkened by 40 percent via after-scale."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(
///     x: "x", y: "y", fill: "sp",
///     colour: after-scale((_, ctx) => {
///       let trained = ctx.trained.at("fill", default: none)
///       let v = ((ctx.resolve-colour)(trained, ctx.palette))(ctx.row.sp)
///       v.darken(40%)
///     }),
///   ),
///   layers: (geom-point(size: 5pt, stroke: 0.8pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@aes
#let after-scale(expr) = (kind: "after-scale", expr: expr)

/// Compose all three late-binding lanes for a single aesthetic.
///
/// `start` (column name) names the column used during initial scale
/// training, before the stat runs. `after-stat` (string column name or
/// `(row, ctx) => any`) takes effect after the stat. `after-scale`
/// (`(value, ctx) => any`) post-transforms the channel's resolved
/// scale value just before draw. Any lane may be `none`.
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param start Column name used for initial training, or `none`.
///
/// \@param after-stat Post-stat expression, or `none`.
///
/// \@param after-scale Post-scale closure, or `none`.
/// \@returns Late-binding marker consumed by \@aes.
///
/// \@examples Train the outline colour on the same column as `fill`, then darken the resolved swatch per row.
/// ```
/// //| alt: "Scatter chart of four points whose outline trains on the fill column and darkens the resolved swatch via stage."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
///   (x: 4, y: 5, sp: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(
///     x: "x", y: "y", fill: "sp",
///     colour: stage(start: "sp", after-scale: (c, _) => c.darken(40%)),
///   ),
///   layers: (geom-point(size: 5pt, stroke: 0.8pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@after-stat, \@after-scale, \@aes
#let stage(start: none, after-stat: none, after-scale: none) = (
  kind: "stage",
  start: start,
  "after-stat": after-stat,
  "after-scale": after-scale,
)

/// Replace stage markers in `mapping` with their `start` column ref so
/// scale training and stat application see plain column names. Returns
/// the rewritten mapping alongside a `stages` dict keyed by channel,
/// which post-stat callers feed back to `apply-stages`.
///
/// \@internal
/// \@param mapping Aesthetic mapping (may carry `stage` markers).
/// \@returns Dict with `mapping` and `stages` fields.
#let stash-stages(mapping) = {
  if mapping == none { return (mapping: mapping, stages: (:)) }
  if not mapping.values().any(v => late-binding-kind(v) == "stage") {
    return (mapping: mapping, stages: (:))
  }
  let stages = (:)
  let new-mapping = mapping
  for (channel, value) in mapping.pairs() {
    if late-binding-kind(value) != "stage" { continue }
    stages.insert(channel, value)
    new-mapping.insert(channel, value.at("start", default: none))
  }
  (mapping: new-mapping, stages: stages)
}

/// Apply each stage's after-stat and after-scale lanes against post-stat
/// rows. Stage's after-scale becomes a fresh `after-scale` marker carrying
/// `source: <post-stat-column>` so the per-row resolver scales the source
/// column through the channel's palette before applying the closure.
///
/// \@internal
/// \@param rows Post-stat row dictionaries.
///
/// \@param mapping Aesthetic mapping with stage markers already stashed
///   (positions of stage markers carry plain column refs).
///
/// \@param stages Dict keyed by channel, returned by `stash-stages`.
///
/// \@param ctx Closure context for after-stat closures.
/// \@returns Dict with `rows` and `mapping` fields.
#let apply-stages(rows, mapping, stages, ctx) = {
  if stages.len() == 0 { return (rows: rows, mapping: mapping) }
  let new-mapping = mapping
  let closures = ()
  for (channel, stg) in stages.pairs() {
    let post-col = stg.at("start", default: none)
    let after-stat-expr = stg.at("after-stat", default: none)
    if type(after-stat-expr) == str {
      post-col = after-stat-expr
    } else if type(after-stat-expr) == function {
      post-col = _AFTER-STAT-COL-PREFIX + channel
      closures.push((col: post-col, expr: after-stat-expr))
    } else if after-stat-expr != none {
      panic(
        "stage["
          + channel
          + "].after-stat: must be string or function; got "
          + str(type(after-stat-expr)),
      )
    }
    let after-scale-expr = stg.at("after-scale", default: none)
    if after-scale-expr != none {
      let marker = after-scale(after-scale-expr)
      marker.insert("source", post-col)
      new-mapping.insert(channel, marker)
    } else if post-col != none {
      new-mapping.insert(channel, post-col)
    }
  }
  let new-rows = if closures.len() == 0 { rows } else {
    rows.map(row => {
      let r = row
      for c in closures { r.insert(c.col, (c.expr)(row, ctx)) }
      r
    })
  }
  (rows: new-rows, mapping: new-mapping)
}

/// Whether a mapping value carries an `after-scale` marker.
///
/// \@internal
/// \@param v Any value.
/// \@returns Boolean.
#let is-after-scale(v) = late-binding-kind(v) == "after-scale"

/// Extract the source column ref carried by an `after-scale` marker, or
/// pass non-marker values through. Used by per-row resolvers to feed the
/// channel's natural scale-resolver without branching on marker shape.
///
/// \@internal
/// \@param spec An aesthetic mapping value.
/// \@returns The source column name or `spec` unchanged.
#let after-scale-source(spec) = {
  if is-after-scale(spec) { spec.at("source", default: none) } else { spec }
}

/// Apply an `after-scale` marker to a freshly-resolved channel value.
///
/// Builds a one-shot closure context that includes the row, then calls
/// `spec.expr(resolved, ctx-with-row)`. Returns `resolved` unchanged
/// when `spec` is not an `after-scale` marker.
///
/// \@internal
/// \@param resolved The channel's scale-resolved value.
///
/// \@param spec The mapping value for the channel (may be a marker).
///
/// \@param ctx The renderer context (`theme`, `palette`, `trained`, ...).
///
/// \@param row The current data row.
/// \@returns The transformed value, or `resolved` when no marker.
#let apply-after-scale(resolved, spec, ctx, row) = {
  if not is-after-scale(spec) { return resolved }
  (spec.expr)(resolved, (..ctx, row: row))
}

/// Evaluate `after-stat` markers in a mapping against the post-stat
/// rows.
///
/// String exprs rewrite the mapping field to that column name; function
/// exprs synthesise `_as_<channel>` columns over the rows and rewrite
/// the mapping field to that column name. Returns the possibly-augmented
/// rows and rewritten mapping; passes both through untouched when no
/// `after-stat` marker is present.
///
/// \@internal
/// \@param rows Post-stat row dictionaries.
///
/// \@param mapping Aesthetic mapping (may carry `after-stat` markers).
///
/// \@param ctx Closure context (`theme`, `palette`, ...).
/// \@returns Dict with `rows` and `mapping` fields.
#let eval-after-stat(rows, mapping, ctx) = {
  if mapping == none { return (rows: rows, mapping: mapping) }
  let new-mapping = mapping
  let closures = ()
  let outputs = if "stat-info" in ctx { ctx.stat-info.outputs } else { () }
  let stat-name = ctx.at("stat-name", default: "?")
  for (channel, value) in mapping.pairs() {
    if late-binding-kind(value) != "after-stat" { continue }
    let expr = value.expr
    if type(expr) == str {
      if outputs.len() > 0 and not outputs.contains(expr) {
        panic(
          "after-stat["
            + channel
            + "]: '"
            + expr
            + "' is not in the outputs of stat '"
            + stat-name
            + "'; valid outputs are: "
            + outputs.join(", "),
        )
      }
      new-mapping.insert(channel, expr)
    } else if type(expr) == function {
      let col = _AFTER-STAT-COL-PREFIX + channel
      closures.push((channel: channel, col: col, expr: expr))
      new-mapping.insert(channel, col)
    } else {
      panic(
        "after-stat["
          + channel
          + "]: expr must be a string or function; got "
          + str(type(expr)),
      )
    }
  }
  if closures.len() == 0 { return (rows: rows, mapping: new-mapping) }
  let new-rows = rows.map(row => {
    let r = row
    for c in closures { r.insert(c.col, (c.expr)(row, ctx)) }
    r
  })
  (rows: new-rows, mapping: new-mapping)
}

#let _path-parts(path) = {
  if type(path) == str { return path.split(".") }
  if type(path) == array { return path }
  panic(
    "from-theme: path must be a string or array; got " + str(type(path)),
  )
}

/// Resolve a `from-theme(path)` marker against a merged theme dictionary.
///
/// Walks each key of the path through nested dictionaries; panics with a
/// readable message when a key is missing or the cursor is no longer a
/// dictionary halfway through the walk.
///
/// \@internal
/// \@param theme Merged theme dictionary.
///
/// \@param path Dotted string or array of keys.
/// \@returns The resolved scalar (often a colour or length).
#let resolve-from-theme(theme, path) = {
  let parts = _path-parts(path)
  if parts.len() == 0 {
    panic("from-theme: empty path")
  }
  let cur = theme
  let walked = ()
  for part in parts {
    let here = (..walked, part).join(".")
    if type(cur) != dictionary {
      panic(
        "from-theme: cannot descend into "
          + str(type(cur))
          + " at '"
          + part
          + "' in path "
          + here,
      )
    }
    if not (part in cur) {
      panic(
        "from-theme: key '" + part + "' not found in theme at path " + here,
      )
    }
    cur = cur.at(part)
    walked.push(part)
  }
  cur
}
