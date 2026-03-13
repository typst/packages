#import "themes.typ": themes

// 2-column table with alternating row colors
// Table width is reduced
#let table-alternate(
  words,
  theme,
  links-to-writing: false,
  attach-label: none,
) = {
  set table(
    fill: (_, y) => {
      if calc.even(y) { theme.background-alt } else { theme.background }
    },
    stroke: none,
  )

  let cells = words
    .enumerate()
    .map(((i, (left, right))) => (
      table.cell(colspan: 2)[#if links-to-writing {
        link(label("writing-" + str(i)), [#grid(
          columns: (1fr, 1fr),
          inset: 1em,
          align: horizon,
          left, right,
        )])
      } else {
        grid(
          columns: (1fr, 1fr),
          inset: 1em,
          align: horizon,
          left, right,
        )
      }]
    ))
    .flatten()

  block(inset: (x: 2em))[
    #table(
      columns: (1fr, 1fr),
      inset: 0pt,
      align: horizon,
      ..cells,
    )#if attach-label != none { label(attach-label) }
  ]
}

#let words-masked(words, mode: "full") = {
  words
    .enumerate()
    .map(((i, (a, b))) => {
      if mode == "right" {
        ("", b)
      } else if mode == "left" {
        (a, "")
      } else {
        (a, b)
      }
    })
}

// Unified table function that handles all vocabulary table types
#let table-vocab(
  words,
  theme,
  mode: "full",
  links-to-writing: false,
  attach-label: false,
) = {
  let label-name = if attach-label { mode } else { none }
  table-alternate(
    words-masked(words, mode: mode),
    theme,
    links-to-writing: links-to-writing,
    attach-label: label-name,
  )
}

// Table for writing practice
// First row is highlighted and contains the word pair.
// Left word is shifted to the right.
// Variable number of writing lines with dotted underlines.
// The table is not allowed to break and span across pages.
#let writing-table(
  index,
  word-pair,
  num_lines: 4,
  theme,
  create-backlinks: false,
  backlink-target: none,
) = {
  set table(
    fill: (_, y) => {
      if y == 0 { theme.accent } else { theme.background }
    },
    stroke: none,
  )

  let (word, translation) = word-pair

  let translation-cell = if create-backlinks and backlink-target != none {
    [#translation #h(1fr) #link(label(backlink-target), [#set text(
          font: "New Computer Modern",
        ); #sym.arrow.l.turn]) #h(
        2em,
      )]
  } else {
    [#translation]
  }

  let lines = (
    [#h(1em) #word #label("writing-" + str(index))],
    translation-cell,
  )

  for _ in range(num_lines) {
    lines.push(
      table.cell(colspan: 2, stroke: (
        bottom: (paint: theme.separator, thickness: 0.1em, dash: "dotted"),
      ))[#box(height: 1em)],
    )
  }

  pad(bottom: 1em, block(breakable: false)[
    #table(
      columns: (1fr, 1fr),
      inset: 1em,
      align: horizon,
      ..lines,
    )
  ])
}

// For each word pair, create a writing practice table
#let tables-writing(
  words,
  num-writing-lines,
  theme,
  create-backlinks: false,
  backlink-target: none,
) = {
  for (i, word-pair) in words.enumerate() {
    writing-table(
      i,
      word-pair,
      num_lines: num-writing-lines,
      theme,
      create-backlinks: create-backlinks,
      backlink-target: backlink-target,
    )
  }
}

#let shuffle-words(words, seed) = {
  let seed = datetime.today().day() * decimal(seed)
  let shuffled = words
  for i in range(shuffled.len() - 1, 0, step: -1) {
    let j = calc.rem(calc.floor(seed / (i + 1)), i + 1)
    (shuffled.at(i), shuffled.at(j)) = (shuffled.at(j), shuffled.at(i))
  }
  shuffled
}
