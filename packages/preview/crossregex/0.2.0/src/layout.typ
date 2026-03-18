#import "regex.typ": regex-match

#let centered(body) = {
  context {
    let size = measure(body)
    move(dx: -size.width / 2, dy: -size.height / 2, body)
  }
}

#let build-char-box(width, height, cell-config, alphabet) = {
  ch => {
    set text(
      ..cell-config.text-style,
      fill: if ch.match(alphabet) != none {
        cell-config.valid-color
      } else {
        cell-config.invalid-color
      },
    )
    ch
  }
}

#let build-decoration(positioner, height, deco-config, alphabet) = {
  let hint-marker = if deco-config.hint-marker == auto {
    r => circle(
      radius: 0.2em,
      fill: if r == none {
        yellow
      } else if r {
        green
      } else {
        red
      },
    )
  } else {
    deco-config.hint-marker
  }
  let regex-box = if deco-config.regex-style == auto {
    box.with(fill: gray.transparentize(90%), outset: (x: 0.1em, y: 0.2em), radius: 0.2em)
  } else {
    deco-config.regex-style
  }

  (constraints, a) => {
    show raw.where(block: false): regex-box

    for (i, cons) in constraints.enumerate() {
      let check-result = if regex-match("^" + cons + "$", a.at(i)) {
        if a.at(i).clusters().all(x => x.match(alphabet) != none) {
          true
        } else {
          none
        }
      } else {
        false
      }

      let (x, y) = positioner(i)
      if hint-marker != none {
        place(
          dx: x + deco-config.hint-offset,
          dy: y,
          centered(hint-marker(check-result)),
        )
      }

      // place constraint expressions
      place(
        dx: x + deco-config.regex-offset,
        dy: y - height * 0.5,
        box(height: height, align(horizon, raw(cons, lang: "re"))),
      )
    }
  }
}

#let build-layout(
  angle: none,
  rows: none,
  row-len: none,
  cell: none,
  cell-size: none,
  cell-config: none,
  alphabet: none,
  cell-pos: none,
  char-box-size: none,
  deco-pos: none,
  deco-config: none,
  center: none,
  num-views: none,
  view-size: none,
  whole-size: none,
  whole-grid-offset: (0em, 0em),
) = {
  let cell-config = (
    text-style: (:),
    valid-color: blue,
    invalid-color: purple,
  ) + cell-config
  let deco-config = (
    hint-offset: 0.5em,
    hint-marker: auto,
    regex-offset: 1.0em,
    regex-style: auto,
  ) + deco-config

  let large-shape = for i in range(rows) {
    for j in range(row-len(i)) {
      let (x, y) = cell-pos(i, j)
      place(dx: x, dy: y, centered(cell))
    }
  }

  let make-decorates = build-decoration(deco-pos, cell-size, deco-config, alphabet)

  let char-box = build-char-box(..char-box-size, cell-config, alphabet)

  let make-grid(a) = {
    large-shape

    // place cell texts
    for i in range(rows) {
      for j in range(row-len(i)) {
        let (x, y) = cell-pos(i, j)
        place(dx: x, dy: y, centered(char-box(a.at(i).at(j))))
      }
    }
  }

  let puzzle-view(constraints, a) = {
    let (w, h) = view-size
    show: block.with(width: w, height: h)

    make-grid(a)

    place(dx: center.x, dy: center.y, make-decorates(constraints, a))
  }

  let puzzle-whole(constraints, aa) = {
    let (w, h) = whole-size
    show: block.with(width: w, height: h)
    let (dx, dy) = whole-grid-offset
    show: move.with(dx: dx, dy: dy)

    make-grid(aa.at(0))

    for i in range(num-views) {
      place(
        dx: center.x,
        dy: center.y,
        rotate(i * angle, make-decorates(constraints.at(i), aa.at(i))),
      )
    }
  }

  (puzzle-whole: puzzle-whole, puzzle-view: puzzle-view)
}

/// Compose pages
#let doc-layout(whole-maker: none, view-maker: none, num-views: none, progress: none, margin: 0.5em) = {
  if whole-maker != none {
    set page(height: auto, width: auto, margin: margin)

    let pw = whole-maker()
    set block(spacing: 0.5em)
    pw
    progress

    pagebreak(weak: true)
  }

  if view-maker != none {
    set page(height: auto, width: auto, margin: margin)

    for k in range(num-views) {
      let pv = view-maker(k)
      set block(spacing: 0.5em)
      pv
      progress

      pagebreak(weak: true)
    }
  }
}
