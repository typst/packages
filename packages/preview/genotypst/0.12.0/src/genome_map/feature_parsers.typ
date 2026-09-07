#import "../common/interval.typ": _validate-interval
#import "./genome_map_backend.typ": _genome-map-parse-gff

/// Normalizes the feature-type filter for the GFF parser.
///
/// - feature-types (str, array, none): Feature type filter.
/// -> array, none
#let _normalize-gff-feature-types(feature-types) = {
  if feature-types == none {
    return none
  }

  let normalized = if type(feature-types) == str {
    (feature-types,)
  } else {
    assert(
      type(feature-types) == array,
      message: "feature-types must be none, a string, or an array of strings.",
    )
    feature-types
  }

  for feature-type in normalized {
    assert(
      type(feature-type) == str,
      message: "feature-types entries must be strings.",
    )
    assert(
      feature-type.len() > 0,
      message: "feature-types entries must not be empty.",
    )
  }

  normalized
}

/// Normalizes a strand filter for the GFF parser.
///
/// - strand (str, int, none): Strand filter.
/// -> str, none
#let _normalize-gff-strand(strand) = {
  if strand == none {
    return none
  }

  if strand == "positive" or strand == "+" or strand == 1 {
    return "positive"
  }

  if strand == "negative" or strand == "-" or strand == -1 {
    return "negative"
  }

  assert(
    false,
    message: "strand must be none, 'positive', '+', 1, 'negative', '-', or -1.",
  )
}

/// Validates a GFF attribute name used for feature labels.
///
/// - label-attribute (str): Attribute key to use for labels.
/// -> str
#let _validate-gff-label-attribute(label-attribute) = {
  assert(
    type(label-attribute) == str,
    message: "label-attribute must be a string.",
  )
  assert(
    label-attribute.len() > 0,
    message: "label-attribute must not be empty.",
  )
  label-attribute
}

/// Normalizes the GFF range filter.
///
/// - range-filter (array, none): Range filter as `(accession, start, end)`.
/// -> dictionary, none
#let _normalize-gff-range(range-filter) = {
  if range-filter == none {
    return none
  }

  assert(
    type(range-filter) == array,
    message: "range must be none or an array.",
  )
  assert(
    range-filter.len() == 3,
    message: "range must contain exactly accession, start, and end.",
  )

  let accession = range-filter.at(0)
  assert(type(accession) == str, message: "range accession must be a string.")
  assert(
    accession.len() > 0,
    message: "range accession must not be empty.",
  )

  let start = range-filter.at(1)
  let end = range-filter.at(2)
  _validate-interval(
    start,
    end,
    start-name: "range.at(1)",
    end-name: "range.at(2)",
    min: 1,
  )

  (accession: accession, start: start, end: end)
}

/// Parses GFF3-formatted feature data into genome-map feature dictionaries.
///
/// Returned features can be passed directly to `render-genome-map`.
///
/// - data (str): GFF3-formatted feature data.
/// - feature-types (str, array, none): Feature type or feature types to keep. If none, keeps all feature types (default: none).
/// - range (array, none): Genomic range to keep as `(accession, start, end)`. `start` and `end` may be none (default: none).
/// - strand (str, int, none): Strand to keep: "positive", "+", 1, "negative", "-", or -1. If none, keeps all strands (default: none).
/// - exclude-partial (bool): Whether to omit features that would be clipped by a range (default: false).
/// - label-attribute (str): Attribute key used for feature labels. Features without this attribute have no label (default: "ID").
/// -> array of dictionaries with keys:
///   - start (int): Feature start coordinate after clipping.
///   - end (int): Feature end coordinate after clipping.
///   - strand (int, none): Feature strand as 1, -1, or none.
///   - label (str, none): Feature label.
///   - partial (bool): Whether the feature was clipped by a range.
///   - accession (str): Feature accession.
///   - feature-type (str): GFF3 feature type.
///   - source (str): GFF3 source.
///   - score (float, none): GFF3 score.
///   - phase (int, none): GFF3 phase.
///   - attributes (dictionary): GFF3 attributes, with values as arrays of strings.
///   - original-start (int): Feature start before clipping.
///   - original-end (int): Feature end before clipping.
#let parse-gff(
  data,
  feature-types: none,
  range: none,
  strand: none,
  exclude-partial: false,
  label-attribute: "ID",
) = {
  assert(type(data) == str, message: "data must be a string.")
  assert(
    type(exclude-partial) == bool,
    message: "exclude-partial must be a boolean.",
  )

  _genome-map-parse-gff(data, (
    feature_types: _normalize-gff-feature-types(feature-types),
    range: _normalize-gff-range(range),
    strand: _normalize-gff-strand(strand),
    exclude_partial: exclude-partial,
    label_attribute: _validate-gff-label-attribute(label-attribute),
  ))
}
