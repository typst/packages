// Typeset regression tables. Statistics stay outside Typst: the caller
// passes finished results, and this package only lays them out.

// Format a number with a fixed count of decimals and a true minus sign.
#let format-number(x, digits: 3) = {
  let r = calc.round(calc.abs(x), digits: digits)
  let parts = str(r).split(".")
  let frac = if parts.len() > 1 { parts.at(1) } else { "" }
  while frac.len() < digits { frac += "0" }
  let out = parts.at(0) + if digits > 0 { "." + frac }
  if x < 0 and r != 0 { "−" + out } else { out }
}

// Default levels: p below the first value gets the second value.
#let default-levels = ((0.01, "***"), (0.05, "**"), (0.1, "*"))

// Return the star string for a result. Use `p` when present.
// Otherwise use the normal critical values 2.576, 1.960, and 1.645.
#let stars-for(entry, levels: default-levels) = {
  let p = entry.at("p", default: none)
  if p != none {
    for (limit, mark) in levels {
      if p < limit { return mark }
    }
    return ""
  }
  let t = calc.abs(entry.coef / entry.se)
  let cut = (2.5758, 1.96, 1.6449)
  for (i, c) in cut.enumerate() {
    if t > c { return levels.at(i).at(1) }
  }
  ""
}

#let default-labels = (
  N: [Observations],
  R2: [$R^2$],
  adj_R2: [Adjusted $R^2$],
)

// Build a regression table.
//
// models: array of dictionaries. Each has `name` (header), `coefficients`
//   (dictionary: variable -> (coef, se, p)), and `stats` (dictionary).
// labels: dictionary that maps a variable or stat key to display content.
// order: variable keys to show, in order. Default: order of first use.
// stats: stat keys to show, in order. Default: keys of the first model.
// digits: decimals for coefficients and stats.
// levels: significance levels as (limit, mark) pairs, strictest first.
// notes: `auto` for the standard note, `none` for no note, or content.
#let regression-table(
  models,
  labels: (:),
  order: auto,
  stats: auto,
  digits: 3,
  levels: default-levels,
  notes: auto,
) = {
  let label(key) = labels.at(key, default: default-labels.at(key, default: key))

  let vars = if order != auto { order } else {
    let seen = ()
    for m in models {
      for key in m.coefficients.keys() {
        if key not in seen { seen.push(key) }
      }
    }
    seen
  }
  let stat-keys = if stats != auto { stats } else { models.first().at("stats", default: (:)).keys() }

  let cols = models.len() + 1
  let cell(x) = if type(x) == int { str(x) } else if type(x) == float { format-number(x, digits: digits) } else { x }

  let rows = ()
  for v in vars {
    rows.push(label(v))
    for m in models {
      let e = m.coefficients.at(v, default: none)
      rows.push(if e == none { [] } else { [#format-number(e.coef, digits: digits)#super(stars-for(e, levels: levels))] })
    }
    rows.push([])
    for m in models {
      let e = m.coefficients.at(v, default: none)
      rows.push(if e == none { [] } else { [(#format-number(e.se, digits: digits))] })
    }
  }

  let stat-rows = ()
  for k in stat-keys {
    stat-rows.push(label(k))
    for m in models {
      let s = m.at("stats", default: (:)).at(k, default: none)
      stat-rows.push(if s == none { [] } else { cell(s) })
    }
  }

  let note = if notes == auto {
    let marks = levels.map(((limit, mark)) => [#mark~$p < #limit$])
    [_Notes:_ Standard errors in parentheses. #marks.join([, ])]
  } else { notes }

  block(breakable: false, {
    table(
      columns: (auto,) + (1fr,) * models.len(),
      align: (left,) + (center,) * models.len(),
      stroke: none,
      inset: (x: 6pt, y: 3pt),
      table.hline(stroke: 1pt),
      [], ..models.enumerate(start: 1).map(((i, _)) => [(#i)]),
      [], ..models.map(m => m.name),
      table.hline(stroke: 0.5pt),
      ..rows,
      table.hline(stroke: 0.5pt),
      ..stat-rows,
      table.hline(stroke: 1pt),
    )
    if note != none { align(left, text(size: 0.85em, note)) }
  })
}
