///! Temporal position scales: date, datetime, and time.
///!
///! These wrappers train a continuous numeric domain like \@scale-continuous
///! and only differ at axis-label time, where the numeric break is converted
///! back to a Typst `datetime` against a fixed epoch and rendered through
///! `dt.display(date-format)`.
///!
///! Input contract: column values may be numeric (already encoded against
///! the epoch documented on each scale) or ISO-8601 strings, which the
///! scale parses on the fly during training.

#let _temporal-scale(
  aesthetic,
  temporal,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: none,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  temporal: temporal,
  date-format: date-format,
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
)
