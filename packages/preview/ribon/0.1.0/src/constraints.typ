#let constraint-pair(i, j) = (i: i, j: j)

/// Construct a position-specific pseudo-energy in kcal/mol.
#let position-energy(position, energy) = (
  position: position,
  energy-kcal-mol: energy,
)

/// Construct a base-pair-specific pseudo-energy in kcal/mol.
#let pair-energy(i, j, energy) = (
  i: i,
  j: j,
  energy-kcal-mol: energy,
)

/// Build generic soft constraints for unpaired, paired, pair, and stack terms.
#let soft-constraints(unpaired: (), paired: (), pairs: (), stack: ()) = (
  unpaired: unpaired,
  paired: paired,
  pairs: pairs,
  stack: stack,
)

/// Build SHAPE/DMS probing input. `method` is `"deigan"` or
/// `"zarringhalam"`; null/negative reactivities are treated as missing.
#let probing-data(
  reactivities,
  kind: "shape",
  method: "deigan",
  slope: 1.8,
  intercept: -0.6,
  beta: 0.89,
  conversion: "O",
  default-probability: 0.5,
) = (
  kind: kind,
  method: method,
  reactivities: reactivities,
  slope: slope,
  intercept: intercept,
  beta: beta,
  conversion: conversion,
  default-probability: default-probability,
)

/// Build a constraint dictionary shared by MFE, partition, decoding, and
/// fixed-structure evaluation.
#let folding-constraints(
  force-unpaired: (),
  force-paired: (),
  force-pairs: (),
  forbid-pairs: (),
  max-span: none,
  no-gu: false,
  no-lonely-pairs: false,
  soft: soft-constraints(),
  probing: none,
) = (
  force-unpaired: force-unpaired,
  force-paired: force-paired,
  force-pairs: force-pairs,
  forbid-pairs: forbid-pairs,
  max-span: max-span,
  no-gu: no-gu,
  no-lonely-pairs: no-lonely-pairs,
  soft: soft,
  probing: probing,
)

/// Convert probing reactivities from an analysis/constraint result or array
/// into VARNA-style nucleotide color annotations.
