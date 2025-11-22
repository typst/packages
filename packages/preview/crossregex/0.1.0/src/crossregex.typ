#import "regex.typ": regex-match

#let r3 = calc.sqrt(3)

#let hexagon = rotate(30deg, polygon.regular(size: 2em, vertices: 6, stroke: 0.5pt))

#let char-box(ch) = box(
  width: r3 * 1em,
  height: 1.5em,
  align(center + horizon)[
    #set text(
      size: 1.2em,
      fill: if ch.match(regex("[A-Z]")) != none {
        blue
      } else {
        purple
      },
    )
    #ch
  ],
)

/// Make a wonderful crossregex game.
///
/// - size (int): the size of the grids, namely the number of cells on the edge.
/// - constraints (array): All constraint regular expressions, given in clockwise order.
/// - answer (none, array, content): Your answers, either a multi-line raw block or an array of strings. The character in one cell is represented as a char in the string.
/// - show-whole (bool): Whether to show all constraints in one page.
/// - show-views (bool): Whether to show three views separately.
#let crossregex(size, constraints: (), answer: none, show-whole: true, show-views: true) = {
  let n1 = size - 1
  let n2 = size * 2 - 1

  let total = 3 * size * (size - 1) + 1
  let filled = 0

  // transform constraints
  if constraints.len() != n2 * 3 {
    panic("Wrong constraint size. Expected " + str(n2 * 3) + ", received " + str(constraints.len()))
  }
  constraints = constraints.map(t => if type(t) == content {
    t.text
  } else {
    t
  })
  let max-len = calc.max(..constraints.map(t => t.len()))
  constraints = constraints.chunks(n2)

  // get the answer strings, and pad them
  let a = if answer == none {
    ()
  } else if type(answer) == array {
    answer
  } else {
    answer.text.split("\n")
  }
  if a.len() < n2 {
    a += ("",) * (n2 - a.len())
  }
  for i in range(n2) {
    let len = n2 - calc.abs(i - n1)
    if a.at(i).len() < len {
      a.at(i) += " " * (len - a.at(i).len())
    }
    a.at(i) = a.at(i).slice(0, len)
    // count letters
    for c in a.at(i) {
      if c.match(regex("[A-Z]")) != none {
        filled += 1
      }
    }
  }

  // build other views
  let b = for i in range(n2) {
    (
      for j in range(n2 - calc.abs(i - n1)) {
        (a.at(n2 - 1 - j - calc.max(i - n1, 0)).at(calc.min(calc.min(i + n1, n2 - 1) - j, i)),)
      }.join(),
    )
  }
  let c = for i in range(n2) {
    (
      for j in range(n2 - calc.abs(i - n1)) {
        (a.at(calc.max(n1 - i, 0) + j).at(calc.min(n2 - 1 - calc.max(i - n1, 0) - j, n2 - i - 1)),)
      }.join(),
    )
  }

  let large-hexagon = for i in range(n2) {
    for j in range(n2 - calc.abs(i - n1)) {
      place(dx: (j + calc.abs(i - n1) * 0.5) * r3 * 1em - 0.1em, dy: i * 1.5em + 0.15em, hexagon)
    }
  }

  let make-decorates(constraints, a) = {
    // place constraint expressions
    show raw.where(block: false): box.with(fill: gray.transparentize(90%), outset: (x: 0.1em, y: 0.2em), radius: 0.2em)

    for (i, cons) in constraints.enumerate() {
      let check-result = if regex-match("^" + cons + "$", a.at(i).replace(regex("[^A-Z]"), " ")) {
        if a.at(i).contains(" ") {
          yellow
        } else {
          green
        }
      } else {
        red
      }

      place(
        dx: (n1 + 0.5 - calc.abs(i - n1) * 0.5) * r3 * 1em + 0.5em,
        dy: (i - n1) * 1.5em,
        move(dx: -0.2em, dy: -0.2em, circle(fill: check-result, radius: 0.2em)),
      )
      place(
        dx: (n1 + 0.5 - calc.abs(i - n1) * 0.5) * r3 * 1em + 1.0em,
        dy: (i - n1 - 0.3) * 1.5em,
        box(height: 1em, align(horizon, raw(cons, lang: "re"))),
      )
    }
  }

  let make-grid-texts(a) = {
    // place cell texts
    for i in range(n2) {
      for j in range(n2 - calc.abs(i - n1)) {
        place(
          dx: (j + calc.abs(i - n1) * 0.5) * r3 * 1em,
          dy: i * 1.5em + 0.3em,
          char-box(a.at(i).at(j)),
        )
      }
    }
  }

  let puzzle-view(constraints, a) = {
    large-hexagon

    place(dx: (n1 + 0.5) * r3 * 1em, dy: n1 * 1.5em + 1em, make-decorates(constraints, a))

    make-grid-texts(a)

    if answer != none {
      place(left + bottom, text(orange)[#filled/#total])
    }
  }

  let aa = (a, b, c)

  // compose pages
  if show-whole {
    let margin-x = max-len * 0.5em + 1em
    let margin-y = max-len * r3 * 0.25em + 1em

    set page(
      height: (n2 + 0.33) * 1.5em + margin-y * 2,
      width: (n2 + 1) * r3 * 1em + margin-x * 1.5,
      margin: (y: margin-y, left: margin-x * 0.66, right: margin-x),
    )

    large-hexagon

    place(
      dx: (n1 + 0.5) * r3 * 1em,
      dy: n1 * 1.5em + 1em,
      make-decorates(constraints.at(0), a),
    )
    place(
      dx: (n1 + 0.5) * r3 * 1em,
      dy: n1 * 1.5em + 1em,
      rotate(120deg, make-decorates(constraints.at(1), b)),
    )
    place(
      dx: (n1 + 0.5) * r3 * 1em,
      dy: n1 * 1.5em + 1em,
      rotate(240deg, make-decorates(constraints.at(2), c)),
    )

    make-grid-texts(a)

    if answer != none {
      place(
        left + bottom,
        dx: -margin-x * 0.66 + 0.5em,
        dy: margin-y - 0.5em,
        text(orange)[#filled/#total],
      )
    }

    pagebreak(weak: true)
  }

  if show-views {
    let margin = 0.5em
    set page(
      height: (n2 + 0.33) * 1.5em + margin * 2,
      width: (n2 + 1) * r3 * 1em + max-len * 0.5em + 1em,
      margin: margin,
    )

    for k in range(3) {
      puzzle-view(constraints.at(k), aa.at(k))
      pagebreak(weak: true)
    }
  }
}
