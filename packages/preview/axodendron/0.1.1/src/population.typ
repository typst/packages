// Population containers, aggregation, and feature-table export.

#import "protocol.typ": _plugin, _request, _required, _unwrap, _require-payload
#import "analysis.typ": _metric-spec, _selection

/// Construct one named population entry.
///
/// - id (str): Stable row identifier.
/// - cell (dictionary): Loaded or transformed morphology.
/// -> dictionary
#let population-entry(id, cell: none) = (
  id: id,
  cell: _required("cell", cell),
)

#let _population(entries) = {
  if type(entries) != array or not entries.all(entry => {
    type(entry) == dictionary and "id" in entry and "cell" in entry
  }) {
    panic("Axodendron: population entries must come from `population-entry`")
  }
  entries
}

/// Validate and retain a lightweight array of population entries.
///
/// - entries (array): Values returned by `population-entry`.
/// -> array
#let population(entries) = _population(entries)

/// Construct one feature-table column.
///
/// Node, section, and bifurcation fields require an explicit aggregate;
/// morphology scalars must leave `aggregate` as `none`.
///
/// - metric (str, dictionary): Metric ID or specification.
/// - name (none, str): Optional stable column name.
/// - aggregate (none, str): Mean, median, extrema, sum, or variance rule.
/// - component (none, str): Explicit component of a vector or box morphology metric.
/// - missing-policy (str): `"strict"` rejects partial fields; `"omit"` explicitly aggregates defined values only.
/// -> dictionary
#let feature-column(metric, name: none, aggregate: none, component: none, missing-policy: "strict") = (
  name: name,
  metric: _metric-spec(metric),
  aggregate: aggregate,
  component: component,
  missing_policy: missing-policy,
)

/// Compute a comparable scalar feature table for multiple morphologies.
///
/// The primary result is Typst-native dictionaries/arrays. Every missing cell
/// retains a reason; descriptive summaries report valid and missing counts and
/// both sample and population variance.
///
/// - population (array): Population returned by `population`.
/// - columns (array): Column specifications returned by `feature-column`.
/// - domain (str): Common selection domain.
/// - kinds (array): Common SWC kind filter.
/// - roots (array): Common subtree root IDs, when meaningful across the population.
/// - nodes (array): Common explicit node IDs, when meaningful across the population.
/// - section-boundaries (str): Common section decomposition rule.
/// -> dictionary
#let feature-table(
  population,
  columns: none,
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
  section-boundaries: "topology-and-type",
) = {
  let population = _population(population)
  let columns = _required("columns", columns)
  _unwrap(_plugin.feature_table(_request((
    population: population.map(entry => (
      id: entry.at("id"),
      payload: _require-payload(entry.at("cell")),
    )),
    options: (
      columns: columns,
      selection: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
      section_boundaries: section-boundaries,
    ),
  ))))
}

/// Serialize a feature table as RFC 4180-style CSV text.
///
/// Missing cells are empty. This function returns text and performs no file I/O.
///
/// - table (dictionary): Result returned by `feature-table`.
/// -> str
#let feature-table-csv(table) = _unwrap(_plugin.feature_table_csv(_request(table)))
