#let apa-table(
  headers: none,
  ..args,
) = {
  table(
    stroke: 0pt,
    table.hline(stroke: 1pt),
    table.header(..headers),
    table.hline(stroke: 1pt),
    ..args,
    table.hline(stroke: 1pt)
  )
}

#let apa-figure(
  body,
  ..args,
  note: none,
  specific-note: none,
  probability-note: none,
) = {
  figure(
    [
      #set par(first-line-indent: 0em)
      #body
      #set align(left)
      #if note != none [
        #emph[Nota.]
        #note
      ]
      #parbreak()
      #specific-note
      #parbreak()
      #probability-note
    ],
    ..args,
  )
}

#import "@preview/wordometer:0.1.6": utils as wordometer

/// https://apastyle.apa.org/style-grammar-guidelines/citations/quotations
#let apa-quote(it) = context {
  let stats = wordometer.word-count-of(it.body)

  let threshold = 40
  let count = stats.words

  let is-block = it.block or count >= threshold

  let attribution = if type(it.attribution) == label {
    cite(it.attribution)
  } else {
    it.attribution
  }

  if is-block {
    block(inset: (left: 0.5in))[
      #set par(first-line-indent: 0pt)
      #it.body
      #if attribution != none {
        h(0.25em)
        attribution
      }
    ]
  } else {
    ["#it.body"]
    if attribution != none {
      h(0.25em)
      attribution
    }
  }
}
