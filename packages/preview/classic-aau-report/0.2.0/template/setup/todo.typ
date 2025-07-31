// Heavily modified version of https://github.com/ntjess/typst-drafting/
// included as a file here whilst waiting on
// https://github.com/ntjess/typst-drafting/pull/18

#import "@preview/t4t:0.4.1": get

#let note-descent = state("note-descent", (:))

#let note-outline(title: "List of Todos", level: 1, row-gutter: 10pt) = context {
  heading(level: level, title)


  let notes = query(<margin-note>).map(note => {
    show: box // do not break entries across pages
    link(
      note.location().position(),
      grid(
        columns: (1em, 1fr, 10pt),
        column-gutter: 5pt,
        align: (top, bottom, bottom),
        box(
          fill: note.fill,
          stroke: note.stroke,
          width: 1em,
          height: 1em,
        ),
        // could do raw note.body, but then font 9pt by default...
        [#get.text(sep: " ", note.body) #box(width: 1fr, repeat[.])],
        [#note.location().page()]
      )
    )
  })

  grid(
    row-gutter: row-gutter,
    ..notes
  )
}

#let _get-current-descent(descents-dict, page-number: auto) = {
  if page-number == auto {
    page-number = descents-dict.keys().at(-1, default: "0")
  } else {
    page-number = str(page-number)
  }
  (page-number, descents-dict.at(page-number, default: (left: 0pt, right: 0pt)))
}

#let _update-descent(side, dy, anchor-y, note-rect, page-number) = {
  let height = measure(note-rect).height
  let dy = (dy + height + anchor-y).to-absolute()
  note-descent.update(old => {
    let (cnt, props) = _get-current-descent(old, page-number: page-number)
    props.insert(side, dy)
    old.insert(cnt, props)
    old
  })
}

#let _get-margin(side: auto, page-num) = {
  let page-dims = (page.width, page.height)
  let default-margin = 2.5 / 21 * calc.min(..page-dims)
  let defaults = (
    "left": default-margin,
    "right": default-margin
  )
  // no margin is specified at all
  if (page.margin == auto) {
    return defaults
  }

  if ("right" in page.margin.keys() and page.margin.right != auto) {
    defaults.at("right") = page.margin.right
  }
  if ("left" in page.margin.keys() and page.margin.left != auto) {
    defaults.at("left") = page.margin.left
  }
  if ("inside" in page.margin.keys() and page.margin.inside != auto) {
    if (calc.odd(page-num)) {
      defaults.at("left") = page.margin.inside
    } else {
      defaults.at("right") = page.margin.inside
    }
  }
  if ("outside" in page.margin.keys() and page.margin.outside != auto) {
    if (calc.even(page-num)) {
      defaults.at("left") = page.margin.outside
    } else {
      defaults.at("right") = page.margin.outside
    }
  }
  return defaults
}

#let _todo-right(body, dy, anchor-x, anchor-y, font-size, font-color, color) = {
  let w = page.width
  let m = _get-margin(side: right, here().page()).right
  let dist-to-margin = w - anchor-x - m

  let path-pts = (
    (0pt, -.2em),
    (0pt, 2pt),
    (dist-to-margin - 2pt, 2pt),
    (dist-to-margin - 2pt, dy + 2pt),
    (dist-to-margin + 2pt, dy + 2pt),
  )

  dy += 1pt // todo-spacing
  let note-rect = rect(
    stroke: .5pt, 
    fill: color,
    width: m - 10pt, // todo-margin
    inset: 4pt,
    radius: 4pt,
    text(size: font-size,
    fill: font-color,
    body)
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: 1pt + color, ..path-pts))
    #place(dx: dist-to-margin + 2pt, dy: dy - 10pt)[#note-rect<margin-note>] // lift todo a bit
  ]
  _update-descent("right", dy, anchor-y, note-rect, here().page())
}

#let _todo-left(body, dy, anchor-x, anchor-y, font-size, font-color, color) = {
  let w = page.width
  let m = _get-margin(side: left, here().page()).left
  let dist-to-margin =  - anchor-x

  let path-pts = (
    (0pt, -.2em),
    (0pt, 2pt),
    (dist-to-margin + m - 8pt, 2pt),
    (dist-to-margin + m - 8pt, 2pt),
    (dist-to-margin + m - 8pt, dy + 2pt),
    (dist-to-margin + m - 10pt - 2pt, dy + 2pt), // todo-margin
  )

  dy += 1pt // todo-spacing
  let note-rect = rect(
    stroke: .5pt,
    fill: color,
    width: m - 10pt, // todo-margin
    inset: 4pt,
    radius: 4pt,
    text(size: font-size, body)
  )

  let foo = measure(note-rect)
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: color, ..path-pts))
    #place(dx: dist-to-margin - 2pt, dy: dy - 10pt)[#note-rect<margin-note>] // lift todo a bit
  ]
  _update-descent("left", dy, anchor-y, note-rect, here().page())
}

#let todo(side: auto, font-size: 9pt, font-color: black, color: orange, body) = [
  #h(0pt) // ensure here().position() accounts for indented paragraphs
  #context {
    let pos = here().position()
    let margin = _get-margin(side: side, pos.page)
    // shadow argument
    let side = if (side == auto) {
      let left = margin.at("left")
      let right = margin.at("right")
      if (left > right) {
        "left"
      } else {
        "right"
      }
    } else {
      repr(side)
    }
    let margin-func = if (side == "right") {
      _todo-right
    } else {
      _todo-left
    }
    let (anchor-x, anchor-y) = (pos.x - 5pt, pos.y)

    let (cur-page, descents) = _get-current-descent(note-descent.get(), page-number: pos.page)
    let cur-descent = descents.at(side)
    let dy = calc.max(0pt, cur-descent - pos.y)

    margin-func(
      body,
      dy,
      anchor-x,
      anchor-y,
      font-size,
      font-color,
      color
    )
  }
]
