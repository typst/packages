// Work from raw.line.text: Typst has already normalized tabs and line endings.
// Syntax highlighting can split or wrap the leading whitespace arbitrarily.
#let leading-spaces = regex("^ *")

// Vote on observed changes, rather than taking a GCD that collapses to one
// after a single alignment outlier. Ties favor the smaller observed step.
#let detect(rows) = {
  let votes = (:)
  let previous = 0
  for row in rows {
    if row.blank { continue }
    let delta = calc.abs(row.columns - previous)
    if delta > 0 {
      let key = str(delta)
      votes.insert(key, votes.at(key, default: 0) + 1)
    }
    previous = row.columns
  }
  let width = 4
  let best = 0
  for (key, count) in votes {
    let candidate = int(key)
    if count > best or (count == best and candidate < width) {
      width = candidate
      best = count
    }
  }
  width
}

#let scan(lines, width: auto, blank-lines: true) = {
  let rows = lines.map(value => {
    let spaces = value.match(leading-spaces).text
    (columns: spaces.len(), blank: spaces.len() == value.len())
  })
  if width == auto { width = detect(rows) }
  let depths = ()
  let previous = 0
  let pending = 0
  for row in rows {
    if row.blank {
      pending += 1
      continue
    }
    let depth = int(calc.floor(row.columns / width))
    // Only continue levels shared by the surrounding nonblank lines. Leading
    // and trailing blank lines have no inferred guides, regardless of spaces.
    if pending > 0 {
      depths += (if blank-lines { calc.min(previous, depth) } else { 0 },) * pending
      pending = 0
    }
    depths.push(depth)
    previous = depth
  }
  depths += (0,) * pending
  (width: width, depths: depths)
}

#let settings(value, rainbow) = {
  let colored = if value.rainbow == auto { rainbow != none and rainbow.enabled } else {
    value.rainbow
  }
  let colors = if value.palette != auto { value.palette } else if rainbow != none {
    rainbow.palette
  } else {
    import "rainbow.typ": palette
    palette
  }
  let offset = if value.depth-offset != auto { value.depth-offset } else if rainbow != none {
    rainbow.depth-offset
  } else { 0 }
  (
    palette: if colored { colors } else { (value.color,) },
    depth-offset: offset,
    thickness: value.thickness,
    x-offset: value.x-offset,
  )
}
