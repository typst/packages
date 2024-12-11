#let stone(
  fill,
  n: none,
  mark: none,
  height: 1em,
  font: "Inter",
  mark-color: rgb("#f24"),
  mark-outline: false,
) = {
  let ch(x) = place(x, center + horizon)
  let tl(x) = place(x, top + left)
  let u = height
  let text = if n == none { "" } else {
    let x = if n > 99 { 60% } else if n > 19 { 80% } else { 100% }
    let label = text(
      str(n),
      font: font,
      fill: if fill == none { black } else { fill.negate() },
      size: 0.7 * u,
    )
    scale(ch(label), x: x)
  }
  let stroke = if fill != none { black + 0.05 * u } else { none }
  let content = ch(circle(text, width: 0.95 * u, stroke: stroke, fill: fill))
  if mark == "triangle" {
    let stroke = if mark-outline { black + 0.05 * u } else { none }
    content += ch(
      move(
        dy: -0.05 * u,
        polygon.regular(
          vertices: 3,
          size: 0.55 * u,
          fill: mark-color,
          stroke: stroke,
        ),
      ),
    )
  } else if mark == "circle" {
    if mark-outline {
      content += ch(circle(width: 0.5 * u, stroke: black + 0.2 * u))
    }
    content += ch(circle(width: 0.5 * u, stroke: mark-color + 0.1 * u))
  } else if mark == "square" {
    let stroke = if mark-outline { black + 0.05 * u } else { none }
    content += ch(
      rect(width: 0.4 * u, height: 0.4 * u, fill: mark-color, stroke: stroke),
    )
  } else if mark == "cross" {
    if mark-outline {
      let k = calc.sqrt(2) * 0.025 * u
      content += tl(
        line(
          start: (30% - k, 30% - k),
          end: (70% + k, 70% + k),
          stroke: black + 0.2 * u,
        ),
      )
      content += tl(
        line(
          start: (70% + k, 30% - k),
          end: (30% - k, 70% + k),
          stroke: black + 0.2 * u,
        ),
      )
    }
    content += tl(
      line(start: (30%, 30%), end: (70%, 70%), stroke: mark-color + 0.1 * u),
    )
    content += tl(
      line(start: (70%, 30%), end: (30%, 70%), stroke: mark-color + 0.1 * u),
    )
  }
  let r = rect(content, width: height, height: height, stroke: none, inset: 0%)
  box(ch(r), height: 0.6 * height, width: height)
}

#let board(
  notation,
  caption: none,
  scale: 1em,
  font: "Inter",
  placement: none,
  stroke: 0.05em,
  edge-stroke: 0.1em,
  coordinates: false,
  board-color: rgb("#fff"),
  mark-color: rgb("#f24"),
) = {
  let u = scale
  let tl(x) = place(x, top + left)
  let ch(x) = place(x, center + horizon)
  let wood = board-color
  let aka = mark-color
  let lines = notation.split("\n")
  let odd = black
  let rows = ()
  let edge = (top: false, right: false, bottom: false, left: false)
  let width = 1
  let board-size = 19
  let top-1 = false

  for line in lines {
    line = line.trim()
    if line.starts-with(regex("\$\$[BWc]")) {
      // Parse diagram header
      let control = line.match(
        regex("^\$\$([BW])?([cC])?(\d+)?(?:m(\d+))?(?: (.*))?$"),
      )
      if control != none {
        let (bw, c, n, m, cap) = control.captures
        if (bw == "W") == (m == none or calc.odd(int(m))) { odd = white }
        if c != none { coordinates = true }
        if c == "C" { top-1 = true }
        if n != none { board-size = int(n) }
        if caption == none { caption = cap }
      }
    } else if line.trim() != "" {
      // Parse diagram header
      line = line.replace("$$", "").trim()
      let le = line.find(regex("^[-+|]")) != none
      let re = line.find(regex("[-+|]$")) != none
      let row = line
        .matches(regex("\d+|[.,OXBW#@YQZPCSTMa-z]"))
        .map(m => m.text)
      if row != () {
        width = calc.max(width, row.len())
        rows.push(row)
        if le { edge.left = true }
        if re { edge.right = true }
      } else {
        if le or re {
          if rows != () {
            edge.bottom = true
          } else {
            edge.top = true
          }
        }
      }
    }
  }
  let height = rows.len()
  let abc(i) = str.from-unicode(i + if i >= 9 { 65 } else { 64 })
  let coord(x) = rect(
    ch(text(x, font: font, fill: black, size: 0.6 * u)),
    fill: wood,
    width: u,
    height: u,
    inset: 0%,
  )
  let first-col = if edge.left { 1 } else { 1 + board-size - width }
  let first-row = if top-1 {
    if edge.top { 1 } else { 1 + board-size - width }
  } else {
    if edge.top { board-size } else { height }
  }

  let tile(x, y) = {
    let x-off = x == -1 or x == width
    let y-off = y == -1 or y == height
    if x-off and y-off { return coord("") }
    if x-off {
      return coord(str(if top-1 { first-row + y } else { first-row - y }))
    }
    if y-off { return coord(abc(first-col + x)) }
    let row = rows.at(y)
    let cell = if x < row.len() { row.at(x) } else { "." }
    let num = if cell.find(regex("\d")) == none { none } else { int(cell) }
    let eb = y == height - 1 and edge.bottom
    let et = y == 0 and edge.top
    let er = x == width - 1 and edge.right
    let el = x == 0 and edge.left
    let vs = if el or er { edge-stroke } else { stroke }
    let hs = if et or eb { edge-stroke } else { stroke }

    let content = [
      #if cell == "," { ch(circle(width: 0.23 * u, fill: black)) }
      #if cell >= "a" and cell <= "z" {
        let letter = ch(
          text(cell, font: font, size: 0.7 * u, baseline: -0.04 * u),
        )
        ch(circle(letter, width: 0.8 * u, stroke: none, fill: wood))
      } else { }
      #if num != none {
        let col = if calc.odd(int(num)) == (odd == black) { black } else {
          white
        }
        ch(stone(col, n: num, height: u))
      }
      #if cell == "X" { ch(stone(black, height: u)) }
      #if cell == "O" { ch(stone(white, height: u)) }
      #if cell == "B" { ch(stone(black, height: u, mark: "circle")) }
      #if cell == "W" { ch(stone(white, height: u, mark: "circle")) }
      #if cell == "C" {
        ch(stone(none, height: u, mark: "circle", mark-outline: true))
      }
      #if cell == "#" { ch(stone(black, height: u, mark: "square")) }
      #if cell == "@" { ch(stone(white, height: u, mark: "square")) }
      #if cell == "S" {
        ch(stone(none, height: u, mark: "square", mark-outline: true))
      }
      #if cell == "Y" { ch(stone(black, height: u, mark: "triangle")) }
      #if cell == "Q" { ch(stone(white, height: u, mark: "triangle")) }
      #if cell == "T" {
        ch(stone(none, height: u, mark: "triangle", mark-outline: true))
      }
      #if cell == "Z" { ch(stone(black, height: u, mark: "cross")) }
      #if cell == "P" { ch(stone(white, height: u, mark: "cross")) }
      #if cell == "M" {
        ch(stone(none, height: u, mark: "cross", mark-outline: true))
      }
    ]
    rect(content, stroke: none, width: u, height: u, inset: 0%)
  }

  let ys = if coordinates {
    if edge.top { range(-1, height) } else { (..range(height), -1) }
  } else {
    range(height)
  }
  let xs = if coordinates {
    if edge.left { range(-1, width) } else { (..range(width), -1) }
  } else {
    range(width)
  }

  let tiles = ys.map(y => xs.map(x => tile(x, y)))
  let columns = width + if coordinates { 1 } else { 0 }
  let lines = []
  for x in range(width) {
    let e = x == width - 1 and edge.right or x == 0 and edge.left
    let s = if e { edge-stroke } else { stroke }
    let lx = x + 0.5 + if coordinates and edge.left { 1 } else { 0 }
    let ly0 = if coordinates and edge.top { 1 } else { 0 } * u
    let ly1 = ly0 + height * u
    if edge.top { ly0 += 0.5 * u - s / 2 }
    if edge.bottom { ly1 -= 0.5 * u - s / 2 }
    lines += tl(line(start: (lx * u, ly0), end: (lx * u, ly1), stroke: s))
  }
  for y in range(height) {
    let e = y == height - 1 and edge.bottom or y == 0 and edge.top
    let s = if e { edge-stroke } else { stroke }
    let ly = y + 0.5 + if coordinates and edge.top { 1 } else { 0 }
    let lx0 = if coordinates and edge.left { 1 } else { 0 } * u
    let lx1 = lx0 + width * u
    if edge.left { lx0 += 0.5 * u - s / 2 }
    if edge.right { lx1 -= 0.5 * u - s / 2 }
    lines += tl(line(start: (lx0, ly * u), end: (lx1, ly * u), stroke: s))
  }


  let result = box(
    fill: wood,
    lines + grid(columns: columns, ..tiles.flatten()),
  )
  if caption != none {
    figure(result, caption: caption, placement: placement)
  } else {
    result
  }
}
