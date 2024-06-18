#let binary-digits(x, digit: 0) = {
  let digits = range(digit).map(_ => 0)

  while (x != 0) {
    digits.insert(digit, calc.rem-euclid(x, 2))
    x = calc.div-euclid(x, 2)
  }

  return digits.rev().slice(0, digit).rev()
}

#let gray-code(x) = x.bit-xor(x.bit-rshift(1))

#let karnaugh(labels, minterms, implicants: (),
  show-zero: false, mode: "code") = {
  let (X, Y) = range(2).map(i =>
    if (type(labels.at(i)) == str) {
      // Label extracted from character(s)
      labels.at(i).clusters().map(x => eval(x, mode: "math"))
    } else { labels.at(i) }
  )

  // Dimensions: 2^len
  let row = calc.pow(2, X.len())
  let column = calc.pow(2, Y.len())
  let cell = (
    width: 2.4em,
    height: 2.4em,
  )

  let gray-codes(till, digit) = range(till).map(i => gray-code(i)).map(code =>
    block(width: cell.width, height: cell.height, inset: cell.height / 9,
      for digit in binary-digits(code, digit: digit) {
        math.equation[#digit]
      }
    )
  )

  return table(
    rows: row + 1,
    columns: column + 1,
    inset: 0em,
    stroke: (x, y) =>
      if (x == 0 or y == 0) { none } else { 1pt },
    align: (x, y) => {
      if (x == 0 and y != 0) { horizon + right }
      else if (x != 0 and y == 0) { center + bottom }
      else { horizon + center }
    },
    // Top-left label block
    block(width: cell.width, height: cell.height, {
      line(end: (100%, 100%))

      let label = (
        x: box(for x in Y { x }),
        y: box(for y in X { y }),
      )

      context place(horizon + center,
        dx: measure(label.x).width / 2, dy: -0.5em, label.x)
      context place(horizon + center,
        dx: -measure(label.y).width / 2, dy: 0.5em, label.y)
    }),
    // Horizontal gray code labels
    ..if mode == "code" { gray-codes(column, Y.len()) },
    table.cell(x: 1, y: 1,
      rowspan: row, colspan: column,
      block(clip: true, {
        table(
          rows: row,
          columns: column,
          inset: 0em,
          align: horizon + center,
          stroke: 2pt / 3,
          ..range(row).map(i =>
            range(column).map(j =>
              block(width: cell.width, height: cell.height, {
                let term = minterms.at(i).at(j)

                if type(term) == int {
                  if term == 0 {
                    if show-zero { $0$ }
                  } else if term == 1 { $1$ }
                  else { math.ast.small }
                } else { term }
              })
            )
          ).flatten()
        )

        while (implicants.len() > 0) {
          let implicant = implicants.pop()
          let (x, y, width, ..) = implicant
          let height = if implicant.len() == 3 { width } else { implicant.at(3) }

          place(
            top + left,
            dx: y * cell.width,
            dy: x * cell.height,
            rect(
              fill: rgb("#0003"),
              stroke: 2pt / 3,
              width: cell.width * width,
              height: cell.height * height,
              outset: -cell.height / 9)
          )

          // No need to expand out-of-range rectanges from the expanded rectange
          if (implicant.len() == 5 and not implicant.at(4)) { continue }

          // Draw extra out-of-range rectange(s)
          if x + height > row {
            implicants.push((row - x - height, y, width, height, false))
            if y + width > column {
              implicants.push((row - x - height, column - y - width, width, height, false))
            }
          }
          if y + width > column {
            implicants.push((x, column - y - width, width, height, false))
          }
        }
      })
    ),
    ..if mode == "code" { gray-codes(row, X.len()) },
  )
}
