// The game board.
#let board = ```
D D E L I V E R Y P
O P N G K G J G R L
C R E A T U R E S E
U E V L K H F G A U
M G R Y C E Z G M C
E L J T R I L A F T
N M H Q A E H M H D
T I F T K I X E P C
S M O H X I N T V S
K O R O H U A U A Q
```.text.split("\n").map(line => line.split().map(str.trim))

// Did you really think the words would be here in plain text?
#let solution = (
  134676999, 220725935, 104989125, 51446073, 137429505,
  29688040, 46268699, 27656404, 176095840, 174326373,
)

// The movement directions.
#let dirs = (
  (-1, 0), (-1, -1), (0, -1), (1, -1),
  ( 1, 0), ( 1,  1), (0,  1), (-1, 1),
)

// The tile and board sizes.
#let size = 2em
#let w = board.first().len()
#let h = board.len()

// Maps from letters to their occurances.
#let letters = (:)
#for (y, row) in board.enumerate() {
  for (x, c) in row.enumerate() {
    if c in letters {
      letters.at(c).push((x, y))
    } else {
      letters.insert(c, ((x, y),))
    }
  }
}

// Finds a word in the board if it exists.
#let find-word(word) = {
  let a = word.first()
  let b = word.last()
  for start in letters.at(a, default: ()) {
    for (dx, dy) in dirs {
      let ok = true
      let (x, y) = start

      for c in word {
        if board.at(y, default: ()).at(x, default: "") != c {
          ok = false
          break
        }
        x += dx
        y += dy
      }

      if ok {
        return (start, (x - dx, y - dy))
      }
    }
  }
}

// Renders the letter grid.
#let render-board = {
  place(grid(
    columns: w * (size,),
    rows: h * (size,),
    ..board.flatten().map(align.with(center + horizon)),
  ))
}

// Renders a line through a word.
#let render-mark((x1, y1), (x2, y2)) = {
  let extend = size / 4
  let c = size / 2
  let dx = x2 - x1
  let dy = y2 - y1
  let norm = calc.sqrt(calc.pow(dx, 2) + calc.pow(dy, 2))
  let hx = extend * dx / norm
  let hy = extend * dy / norm
  let start = (x1 * size + c - hx, y1 * size + c - hy)
  let end = (x2 * size + c + hx, y2 * size + c + hy)
  place(line(start: start, end: end))
}

// Parses the document's body into an array of words.
#let parse-input(body) = {
  let extract(it) = {
    ""
    if it == [ ] {
      " "
    } else if it.func() == text {
      it.text
    } else if it.func() == [].func() {
      it.children.map(extract).join()
    }
  }
  extract(body)
    .split(regex("\s+"))
    .filter(s => s.len() >= 3)
    .map(upper)
}

// Hash a word.
#let hash(word) = {
  let s1 = 1
  let s2 = 0
  for c in word {
    s1 = calc.rem(s1 + str.to-unicode(c), 65521)
    s2 = calc.rem((s2 + s1), 65521)
  }
  s2 * calc.pow(2, 16) + s1
}

// Displays an informative popup.
#let popup(main, sub: none) = place(center + horizon, rect(
  width: 5.7 * size,
  height: 1.7 * size,
  fill: black,
  stroke: 6pt + white,
  {
    set text(1.25em, fill: white)
    text(1em, main)
    if sub != none {
      v(0.4em, weak: true)
      text(0.5em, sub)
    }
  }
))

// The game template.
#let game(body) = {
  set page(width: (w + 1) * size, height: (h + 2) * size, margin: size / 2)
  set text(font: "VG5000", 25pt)
  set line(stroke: 4pt + green)

  align(center, text(0.8em)[Find the hidden words!])
  v(0.5em)

  render-board

  let words = parse-input(body).dedup()
  let hashes = words.map(hash)
  let found = hashes.filter(hash => hash in solution)
  let got = found.len()
  let total = solution.len()

  for (word, hash) in words.zip(hashes) {
    if hash not in solution { continue }
    let position = find-word(word)
    if position != none {
      render-mark(..position)
    }
  }

  place(bottom + center, text(0.5em)[#got / #total])
  if got == total or 266011376 in hashes {
    popup(sub: [with #words.len() word#if words.len() > 1 [s]])[You win!]
  }
}
