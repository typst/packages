#import "theme.typ": active-theme

#let question-counter = counter("quill-question-counter")

#let question(..args) = [
  #question-counter.step()
  #context {
    let th = active-theme.get()
    let pos = args.pos()
    let named = args.named()

    let title-val = named.at("title", default: named.at("label", default: none))
    let (final-title, body) = if pos.len() > 1 {
      (if title-val != none { title-val } else { pos.at(0) }, pos.at(1))
    } else {
      (title-val, pos.at(0, default: []))
    }

    block(
      width: 100%,
      inset: (x: 1em, y: 0.7em),
      fill: th.primary.lighten(95%),
      radius: (right: 4pt),
      stroke: (left: (paint: th.primary, thickness: 2.5pt)),
      below: 1.3em,
    )[
      #set text(fill: th.text)
      #block(below: 0.5em)[
        #text(weight: "bold", fill: th.primary, size: 1.05em)[Question #question-counter.display()]
        #if final-title != none [
          #text(weight: "bold", fill: th.text, size: 1.05em)[ · #final-title]
        ]
      ]
      #body
    ]
  }
]
#let que = question

#let answer(..args) = context {
  let th = active-theme.get()
  let body = args.pos().at(0, default: [])

  block(
    width: 100%,
    inset: (x: 1em, y: 0.7em),
    fill: th.surface,
    radius: (right: 4pt),
    stroke: (left: (paint: th.accent, thickness: 1.5pt)),
    below: 1.4em,
  )[
    #set text(fill: th.text)
    #block(below: 0.5em)[
      #text(weight: "bold", fill: th.text-muted, size: 0.8em, tracking: 0.08em)[SOLUTION]
    ]
    #body
  ]
}
#let ans = answer

#let note(..args) = context {
  let th = active-theme.get()
  let named = args.named()

  let type-val = named.at("type", default: "info")
  let title-val = named.at("title", default: named.at("label", default: none))
  let body = args.pos().at(0, default: [])

  let (note-color, default-tag) = if type-val == "warning" {
    (th.warning, "WARNING")
  } else if type-val == "tip" {
    (th.tip, "TIP")
  } else {
    (th.info, "NOTE")
  }

  block(
    width: 100%,
    inset: (left: 1em, y: 0.6em),
    fill: note-color.lighten(97%),
    radius: (right: 4pt),
    stroke: (left: (paint: note-color, thickness: 2.5pt)),
    below: 1.2em,
  )[
    #set text(fill: th.text)
    #block(below: 0.4em)[
      #text(weight: "bold", fill: note-color, size: 0.85em, tracking: 0.08em)[#default-tag]
      #if title-val != none [
        #text(weight: "bold", fill: th.text, size: 0.9em)[ · #title-val]
      ]
    ]
    #body
  ]
}

#let kvtable(
  col: 1,
  key-color: none,
  value-color: none,
  border-color: none,
  ..items,
) = context {
  let th = active-theme.get()

  let k-fill = if key-color != none { key-color } else { th.surface }
  let v-fill = if value-color != none { value-color } else { th.background }
  let b-color = if border-color != none { border-color } else { th.border }

  let cols = (28%, 1fr) * col
  let cells = ()
  let chunked = items.pos().chunks(2)
  let total = chunked.len()

  for (idx, pair) in chunked.enumerate() {
    if pair.len() == 2 {
      let is-last = idx == total - 1
      let b-stroke = if is-last { none } else { 0.4pt + b-color }
      cells += (
        table.cell(
          fill: k-fill,
          inset: (x: 10pt, y: 7.5pt),
          stroke: (bottom: b-stroke, right: 0.4pt + b-color, top: none, left: none),
        )[#text(weight: "semibold", fill: th.primary, size: 0.9em)[#pair.at(0)]],
        table.cell(
          fill: v-fill,
          inset: (x: 10pt, y: 7.5pt),
          stroke: (bottom: b-stroke, top: none, left: none, right: none),
        )[#text(fill: th.text, size: 0.9em)[#pair.at(1)]],
      )
    }
  }

  block(
    width: 100%,
    radius: 5pt,
    clip: true,
    stroke: 0.5pt + b-color,
    below: 1.3em,
  )[
    #table(
      columns: cols,
      stroke: none,
      ..cells,
    )
  ]
}
#let kv-table = kvtable

#let watermark(img, width: 100%, mark: none) = {
  box[
    #image(img, width: width)

    #place(bottom + right, dx: -20pt, dy: -20pt)[
      #text(
        size: 16pt,
        weight: "bold",
        fill: yellow,
      )[#mark]
    ]
  ]
}
