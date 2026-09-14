#import "side-margin.typ": calculate-page-margin-box

#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let outline-entry(body) = {
  // invisible figure, s.t. we can reference it in the outline
  // probably depends on https://github.com/typst/typst/issues/147 for a cleaner solution
  hide(
    box(
      height: 0pt,
      width: 0pt,
      figure(
        none,
        kind: "todo",
        supplement: [TODO],
        caption: to-string(body),
        outlined: true,
      ),
    ),
  )
}

#let inline-todo(body) = {
  box(stroke: orange, width: 100%, inset: 4pt)[#body]
  outline-entry(body)
}

#let side-todo(body, position) = {
  context box({
    let text-position = here().position()

    let side = position
    if position == auto {
      if text-position.x > page.width / 2 {
        side = right
      } else {
        side = left
      }
    }

    let page-margin-box = calculate-page-margin-box(side)
    let shift-y = .5em
    let outer-box-inset = 4pt
    let dx = page-margin-box.x - text-position.x

    place(dx: dx, dy: -shift-y)[
      #box(inset: outer-box-inset, width: page-margin-box.width)[
        #box(stroke: orange, width: 100%)[
          #place({
            // defaults for right side
            let line-size = dx
            let line-x = -line-size
            let tick-x = -line-size
            // overwrites for left side
            if side == left {
              line-size = calc.abs(dx) - page-margin-box.width + outer-box-inset
              line-x = page-margin-box.width - outer-box-inset * 2
              tick-x = calc.abs(dx) - outer-box-inset
            }

            place(line(length: line-size, start: (line-x, shift-y), stroke: orange))
            place(line(length: 4pt, start: (tick-x, shift-y), angle: -90deg, stroke: orange))
          })
          // the todo message
          #box(body, inset: 0.2em)
        ]
        #outline-entry(body)
      ]
    ]
  })
}

#let todo(body, position: auto) = {
  assert(
    position in (auto, left, right, "inline"),
    message: "Can only position todo either inline, or on the left or right side.",
  )
  if position == "inline" {
    inline-todo(body)
  } else {
    side-todo(body, position)
  }
}
