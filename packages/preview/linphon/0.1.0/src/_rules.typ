#let rule(..parts, valign: horizon) = {
  parts = parts.pos()
  if parts.len() > 1 {
    parts.insert(1, $arrow$)
  }
  if parts.len() > 3 {
    parts.insert(3, $slash.big$)
  }
  let baseline = 0% + 0.225em
  if valign.y == horizon {
    baseline = 50% - 0.35em
  } else if valign.y == top {
    baseline = 100% - 0.9em
  }
  box(
    baseline: baseline,
    align(
      horizon,
      stack(
        dir: ltr,
        spacing: 0.5em,
        ..parts
      )
    )
  )
}

#let constraint(body, marker: "*", valign: horizon) = {
  let baseline = 0% + 0.225em
  if valign.y == horizon {
    baseline = 50% - 0.35em
  } else if valign.y == top {
    baseline = 100% - 0.9em
  }
  box(
    baseline: baseline,
    align(
      top,
      stack(
        dir: ltr,
        spacing: 0.1em,
        marker,
        body
      )
    )
  )
}
