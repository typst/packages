// Spec validation: reject aesthetic mappings and facet variables that name a
// column absent from the data, so a typo fails loudly instead of resolving to
// an all-`none` column that trains a bogus single level.
//
// A mapped column name is accepted when it exists in the layer's input data or
// in any prepared (post-stat) layer's output. That union covers both stat
// inputs a stat consumes and drops (e.g. the `z` grid a contour reduces) and
// stat outputs a plain mapping names directly (e.g. `colour: "level"` on a
// contour, `label: "label"` on a stat-manual layer). A genuine typo is in
// neither set. Late-binding markers (`after-stat`, `from-theme`, a pure
// `after-scale`) carry no source column and are skipped.

#import "../aes-keys.typ": AES-KEYS
#import "../data.typ": column-names
#import "../geom/registry.typ": GEOMS
#import "../scale/train.typ": mapping-ref-col
#import "../utils/aes-resolve.typ": merge-mapping
#import "../utils/errors.typ": fail, fail-unknown-column, quote-each
#import "../utils/late-binding.typ": after-scale-source, is-late-binding
#import "common.typ": _resolve-data

// Union of the column names every prepared layer publishes after its stat runs.
// Faceted plots concatenate per-panel layers here, so this is a plot-wide set
// rather than a per-layer one; that is deliberate, since a stat-synthesised
// name (`_count`, `level`, ...) is what a plain mapping legitimately targets.
#let _produced-columns(prepared) = {
  let seen = ()
  for layer in prepared {
    for col in column-names(layer.at("data", default: none)) {
      if col not in seen { seen.push(col) }
    }
  }
  seen
}

// Reject a layer that carries its own data but inherits a plot-level aesthetic
// whose column that data lacks: the layer would otherwise draw nothing. Only a
// layer on the identity stat is checked, since any other stat may synthesise
// the column. Empty data carries no column names, so it is skipped; a column
// that exists with `none` cells counts as present. Only an aesthetic the geom
// reads (`spec.reads`) is checked, so a rect layer that draws from its own
// corners does not need the inherited `x` and `y`. Column names are the union
// over all rows, so a ragged row array does not count a column as missing.
#let _validate-inherited(layer, index, plot-mapping, plot-data) = {
  if layer.data == none or plot-mapping == none { return }
  if not layer.at("inherit-aes", default: true) { return }
  let stat = layer.at("stat", default: "identity")
  let stat-name = if type(stat) == dictionary {
    stat.at("name", default: none)
  } else { stat }
  if stat-name != none and stat-name != "identity" { return }
  let rows = _resolve-data(layer, plot-data)
  if type(rows) != array or rows.len() == 0 { return }
  let input = ()
  for row in rows {
    for col in column-names((row,)) {
      if col not in input { input.push(col) }
    }
  }
  if input.len() == 0 { return }
  let geom = GEOMS.at(str(layer.name), default: none)
  if geom == none { return }
  let own = layer.at("mapping", default: none)
  let missing = ()
  for aesthetic in geom.spec.reads {
    if own != none and own.at(aesthetic, default: none) != none { continue }
    let raw = plot-mapping.at(aesthetic, default: none)
    if raw == none { continue }
    let ref = if is-late-binding(raw) { after-scale-source(raw) } else { raw }
    if ref == none or is-late-binding(ref) { continue }
    let col = mapping-ref-col(ref)
    if type(col) != str { continue }
    if col not in input and col not in missing { missing.push(col) }
  }
  if missing.len() > 0 {
    fail(
      "layer " + str(index + 1) + " (geom-" + str(layer.name) + ")",
      "its own data lacks the inherited column(s) "
        + quote-each(missing)
        + "; available columns: "
        + quote-each(input),
      hint: "map the layer's own aesthetics in its `mapping`, or set `inherit-aes: false`",
    )
  }
}

// Check every mapped aesthetic across every layer against the accepted column
// set. Iterates `AES-KEYS` so non-training channels (`group`, `label`,
// `weight`, `z`, the ellipse/spoke channels) are covered too, not just the
// scale-trained aesthetics.
#let _validate-mapping(layers, prepared, plot-mapping, plot-data) = {
  let produced = _produced-columns(prepared)
  for (index, layer) in layers.enumerate() {
    _validate-inherited(layer, index, plot-mapping, plot-data)
    let mapping = merge-mapping(layer, plot-mapping)
    if mapping == none { continue }
    let input = column-names(_resolve-data(layer, plot-data))
    let allowed = input + produced.filter(col => col not in input)
    // No columns to check against (empty data, or a data-free layer such as a
    // pure annotation): skip rather than reject every mapping. A typo on an
    // empty dataset goes uncaught, but there is nothing to draw either.
    if allowed.len() == 0 { continue }
    for aesthetic in AES-KEYS {
      let raw = mapping.at(aesthetic, default: none)
      if raw == none { continue }
      // Mirror `_train-cache`: an `after-scale` stage trains on its `start`
      // column; source-less late-binding markers resolve elsewhere, skip them.
      let ref = if is-late-binding(raw) { after-scale-source(raw) } else { raw }
      if ref == none or is-late-binding(ref) { continue }
      let col = mapping-ref-col(ref)
      // A scalar channel (intercept, slope, ...) is a value, not a column name.
      if type(col) != str { continue }
      if col not in allowed {
        fail-unknown-column("aes", aesthetic, col, allowed)
      }
    }
  }
}

// Check the facet variable(s) against the columns of the plot data and of every
// layer's own data. Faceting partitions each layer's data by these columns.
#let _validate-facet(spec) = {
  if spec.facet == none { return }
  let cols = column-names(spec.data)
  for layer in spec.layers {
    for col in column-names(_resolve-data(layer, spec.data)) {
      if col not in cols { cols.push(col) }
    }
  }
  if cols.len() == 0 { return }
  if spec.facet.name == "wrap" {
    let variable = spec.facet.variable
    if variable not in cols {
      fail-unknown-column("facet-wrap", "variable", variable, cols)
    }
  } else if spec.facet.name == "grid" {
    let roles = (("rows", spec.facet.rows), ("columns", spec.facet.columns))
    for (role, variable) in roles {
      if variable != none and variable not in cols {
        fail-unknown-column("facet-grid", role, variable, cols)
      }
    }
  }
}

/// Panic if any aesthetic mapping or facet variable names an unknown column.
///
/// - spec: Plot spec dict (transformed data, plot mapping, layers, facet).
/// - prepared: Prepared layers (stat-transformed data and mapping).
#let validate-spec(spec, prepared) = {
  _validate-mapping(spec.layers, prepared, spec.mapping, spec.data)
  _validate-facet(spec)
}
