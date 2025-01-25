#let process-args(
  rows: none,
  row-len: none,
  total: none,
  constraints: none,
  constraint-size: none,
  answer: none,
  alphabet: none,
  rotators: (),
  progress-creator: auto,
) = {
  // transform constraints
  if constraints.len() != constraint-size {
    panic("Wrong constraint size. Expected " + str(constraint-size) + ", received " + str(constraints.len()))
  }
  constraints = constraints.map(t => if type(t) == content {
    t.text
  } else {
    t
  })
  let max-len = calc.max(..constraints.map(t => t.len()))
  constraints = constraints.chunks(rows)

  // get the answer strings, and pad them
  let a = if answer == none {
    ()
  } else if type(answer) == array {
    answer
  } else {
    answer.text.split("\n")
  }
  if a.len() < rows {
    a += ("",) * (rows - a.len())
  }

  let filled = 0
  for i in range(rows) {
    let len = row-len(i)
    if a.at(i).len() < len {
      a.at(i) += " " * (len - a.at(i).len())
    }
    a.at(i) = a.at(i).slice(0, len)
    // count letters
    for c in a.at(i) {
      if c.match(alphabet) != none {
        filled += 1
      }
    }
  }

  // build all views
  let aa = (
    a,
    ..for rotator in rotators {
      let b = for i in range(rows) {
        (
          for j in range(row-len(i)) {
            let (x, y) = rotator(i, j)
            (a.at(x).at(y),)
          }.join(),
        )
      }
      (b,)
    },
  )

  if progress-creator == auto {
    progress-creator = (filled, total) => text(orange)[#filled/#total]
  }
  let progress = if progress-creator != none and answer != none {
    progress-creator(filled, total)
  }

  (constraints: constraints, max-len: max-len, answer: answer, filled: filled, a: a, aa: aa, progress: progress)
}
