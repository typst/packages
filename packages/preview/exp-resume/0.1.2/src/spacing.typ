// Soft-recommendation spacing defaults. Override via resume.with(spacing: (...)).

#let default-spacing = (
  leading: 0.55em,
  gap: 0.9em,
  row: 0.7em,

  after-header: 0.25em,
  after-section-title: -10pt,
  after-section-rule: -2pt,

  rule-stroke: 0.8pt + luma(35%),
  link-offset: 4pt,
  row-delta: 0.25pt,
)

#let spacing-state = state("exp-resume-spacing", default-spacing)
